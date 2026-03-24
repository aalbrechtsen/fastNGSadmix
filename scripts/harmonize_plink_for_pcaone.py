#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


BED_HEADER = bytes([0x6C, 0x1B, 0x01])
GENO_TO_CODE = {0: 0, 1: 2, 2: 3, 3: 1}
CODE_TO_GENO = {0: 0, 1: 3, 2: 1, 3: 2}


def read_fam(path: Path) -> list[list[str]]:
    with path.open() as handle:
        return [line.rstrip("\n").split() for line in handle if line.strip()]


def read_bim(path: Path) -> list[list[str]]:
    with path.open() as handle:
        return [line.rstrip("\n").split() for line in handle if line.strip()]


def variant_key(fields: list[str]) -> tuple[str, str, tuple[str, str]]:
    a1, a2 = fields[4].upper(), fields[5].upper()
    return fields[0], fields[3], tuple(sorted((a1, a2)))


def read_bed(prefix: Path, n_ind: int, n_snp: int) -> list[bytearray]:
    path = prefix.with_suffix(".bed")
    bytes_per_snp = (n_ind + 3) // 4
    with path.open("rb") as handle:
        header = handle.read(3)
        if header != BED_HEADER:
            raise ValueError(f"{path} is not a SNP-major PLINK .bed file")
        raw = handle.read()
    expected = bytes_per_snp * n_snp
    if len(raw) != expected:
        raise ValueError(f"{path} has {len(raw)} payload bytes, expected {expected}")

    genotypes = [bytearray(n_snp) for _ in range(n_ind)]
    offset = 0
    for snp_idx in range(n_snp):
        chunk = raw[offset: offset + bytes_per_snp]
        offset += bytes_per_snp
        ind_idx = 0
        for byte in chunk:
            for _ in range(4):
                if ind_idx >= n_ind:
                    break
                code = byte & 0b11
                genotypes[ind_idx][snp_idx] = CODE_TO_GENO[code]
                byte >>= 2
                ind_idx += 1
    return genotypes


def write_bed(path: Path, genotypes: list[bytearray]) -> None:
    n_ind = len(genotypes)
    n_snp = len(genotypes[0]) if genotypes else 0
    bytes_per_snp = (n_ind + 3) // 4
    with path.open("wb") as handle:
        handle.write(BED_HEADER)
        for snp_idx in range(n_snp):
            chunk = bytearray(bytes_per_snp)
            for ind_idx in range(n_ind):
                geno = genotypes[ind_idx][snp_idx]
                code = GENO_TO_CODE[int(geno)]
                byte_idx = ind_idx // 4
                shift = (ind_idx % 4) * 2
                chunk[byte_idx] |= code << shift
            handle.write(chunk)


def write_table(path: Path, rows: list[list[str]]) -> None:
    with path.open("w") as handle:
        for row in rows:
            handle.write("\t".join(map(str, row)) + "\n")


def harmonize(ref_prefix: Path, sample_prefix: Path, out_dir: Path) -> tuple[Path, Path, int]:
    ref_bim = read_bim(ref_prefix.with_suffix(".bim"))
    sample_bim = read_bim(sample_prefix.with_suffix(".bim"))
    ref_fam = read_fam(ref_prefix.with_suffix(".fam"))
    sample_fam = read_fam(sample_prefix.with_suffix(".fam"))

    ref_index = {variant_key(row): idx for idx, row in enumerate(ref_bim)}
    sample_index = {variant_key(row): idx for idx, row in enumerate(sample_bim)}
    overlap_keys = [variant_key(row) for row in sample_bim if variant_key(row) in ref_index]
    if not overlap_keys:
        raise ValueError("No overlapping variants between reference and sample")

    ref_geno = read_bed(ref_prefix, len(ref_fam), len(ref_bim))
    sample_geno = read_bed(sample_prefix, len(sample_fam), len(sample_bim))

    ref_rows: list[list[str]] = []
    sample_rows: list[list[str]] = []
    ref_subset = [bytearray() for _ in range(len(ref_fam))]
    sample_subset = [bytearray() for _ in range(len(sample_fam))]

    for key in overlap_keys:
        ref_idx = ref_index[key]
        sample_idx = sample_index[key]
        ref_row = ref_bim[ref_idx]
        sample_row = sample_bim[sample_idx]

        ref_rows.append(ref_row)
        sample_rows.append(ref_row)

        ref_a1, ref_a2 = ref_row[4].upper(), ref_row[5].upper()
        sample_a1, sample_a2 = sample_row[4].upper(), sample_row[5].upper()
        flip = (ref_a1 == sample_a2 and ref_a2 == sample_a1)

        for ind_idx, row in enumerate(ref_subset):
            row.append(ref_geno[ind_idx][ref_idx])
        for ind_idx, row in enumerate(sample_subset):
            geno = sample_geno[ind_idx][sample_idx]
            if flip and geno != 3:
                geno = 2 - geno
            row.append(geno)

    out_dir.mkdir(parents=True, exist_ok=True)
    ref_out = out_dir / "ref"
    sample_out = out_dir / "sample"

    write_table(ref_out.with_suffix(".fam"), ref_fam)
    write_table(ref_out.with_suffix(".bim"), ref_rows)
    write_bed(ref_out.with_suffix(".bed"), ref_subset)

    write_table(sample_out.with_suffix(".fam"), sample_fam)
    write_table(sample_out.with_suffix(".bim"), sample_rows)
    write_bed(sample_out.with_suffix(".bed"), sample_subset)

    return ref_out, sample_out, len(overlap_keys)


def main() -> None:
    parser = argparse.ArgumentParser(description="Harmonize reference and sample PLINK prefixes for PCAone projection")
    parser.add_argument("--ref", required=True, help="Reference PLINK prefix")
    parser.add_argument("--sample", required=True, help="Projected sample PLINK prefix")
    parser.add_argument("--outdir", required=True, help="Output directory for harmonized prefixes")
    args = parser.parse_args()

    ref_out, sample_out, count = harmonize(Path(args.ref), Path(args.sample), Path(args.outdir))
    print(f"Matched {count} variants")
    print(f"Reference prefix: {ref_out}")
    print(f"Sample prefix: {sample_out}")


if __name__ == "__main__":
    main()
