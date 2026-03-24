#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pkg="https://github.com/Zilong-Li/PCAone/releases/latest/download/PCAone-Linux.zip"
binary="./PCAone"
ref_prefix="data/humanOrigins_7worldPops"
new_prefix="example/NA20502_TSI"
out_dir="results/pcaone"
ref_out="$out_dir/ref"
new_out="$out_dir/new"

mkdir -p "$out_dir"

if [[ ! -x "$binary" ]]; then
  archive="PCAone-Linux.zip"
  wget "$pkg" || curl -LO "$pkg"
  unzip -o "$archive"
  chmod +x "$binary"
fi

echo "Running PCAone reference decomposition"
"$binary" -b "$ref_prefix" -k 10 --printv -o "$ref_out"

ref_sites="$(wc -l < "$ref_out.mbim")"
new_sites="$(wc -l < "$new_prefix.bim")"

if [[ "$ref_sites" -ne "$new_sites" ]]; then
  cat <<EOF
Cannot project example sample with PCAone using the raw repo prefixes.

Reference PCA output sites : $ref_sites
Projected sample sites     : $new_sites

PCAone projection requires the projected PLINK prefix to be harmonized to the
same site set and ordering as the reference decomposition. Harmonize the PLINK
files first, for example with plink/plink2, and then rerun this script.
EOF
  exit 1
fi

echo "Projecting example sample onto reference PCs"
"$binary" -b "$new_prefix" --USV "$ref_out" --project 2 -o "$new_out"

echo "Output files:"
find "$out_dir" -maxdepth 1 -type f | sort
