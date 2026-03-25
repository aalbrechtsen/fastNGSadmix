# Single-BAM Tutorial

This tutorial starts from a single low-coverage BAM file, extracts genotype
likelihoods at the sites in the 1000 Genomes reference panel with `ANGSD`, runs
`fastNGSadmix`, and then uses bootstrap replicates to show uncertainty in the
estimated admixture proportions.

The workflow is based on:

- the `fastNGSadmix` exercise from the PopGen course material
- the 1000 Genomes reference-panel example on the project website

## 1. Build `fastNGSadmix`

From the repository root:

```bash
make
mkdir -p results
```

## 2. Prepare the example data

If you do not already have the data locally:

```bash
mkdir -p data
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/data1000genomes.tar.gz
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/example.tar.gz
tar -xzf data/data1000genomes.tar.gz
tar -xzf data/example.tar.gz
```

This tutorial uses:

- BAM: `example/smallNA12874.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam`
- reference panel sites: `data1000genomes/1000genomesRefPanel.sites`
- reference frequencies: `data1000genomes/refPanel_1000genomesRefPanel.txt`
- reference population counts: `data1000genomes/nInd_1000genomesRefPanel.txt`

## 3. Set the paths

```bash
ANGSD=/home/albrecht/github/angsd/angsd
BAM=example/smallNA12874.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
SITES=data1000genomes/1000genomesRefPanel.sites
REF=data1000genomes/refPanel_1000genomesRefPanel.txt
NIND=data1000genomes/nInd_1000genomesRefPanel.txt
OUT=results/NA12874_1000G
```

## 4. Extract genotype likelihoods with `ANGSD`

Run `ANGSD` only on the SNPs present in the reference panel:

```bash
"$ANGSD" \
  -i "$BAM" \
  -GL 2 \
  -sites "$SITES" \
  -doGlf 2 \
  -doMajorMinor 3 \
  -minMapQ 30 \
  -minQ 20 \
  -doDepth 1 \
  -doCounts 1 \
  -out "$OUT"
```

This writes:

- `results/NA12874_1000G.beagle.gz`
- `results/NA12874_1000G.arg`
- `results/NA12874_1000G.depthSample`
- `results/NA12874_1000G.depthGlobal`

The key file for `fastNGSadmix` is `results/NA12874_1000G.beagle.gz`.

<details>
<summary>Verified command output</summary>

```text
-> Output filenames:
    ->"results/NA12874_1000G.arg"
    ->"results/NA12874_1000G.beagle.gz"
    ->"results/NA12874_1000G.depthSample"
    ->"results/NA12874_1000G.depthGlobal"
-> Total number of sites analyzed: 2077704
-> Number of sites retained after filtering: 5181
```

</details>

## 5. Estimate ancestry proportions with `fastNGSadmix`

Run:

```bash
./fastNGSadmix \
  -likes "$OUT.beagle.gz" \
  -fname "$REF" \
  -Nname "$NIND" \
  -out "$OUT" \
  -whichPops all
```

This writes:

- `results/NA12874_1000G.qopt`
- `results/NA12874_1000G.log`

The main ancestry estimate is in `results/NA12874_1000G.qopt`.

For the tested example run, the estimated admixture proportions were:

```text
FIN   PEL   PJL   CEU   YRI   CHB
0.7436 0.0412 0.2152 0.0000 0.0000 0.0000
```

<details>
<summary>Verified command output</summary>

```text
Overlap: of 5181 sites between input and ref
Chosen pop FIN
Chosen pop PEL
Chosen pop PJL
Chosen pop CEU
Chosen pop YRI
Chosen pop CHB
...
CONVERGENCE!
This many iterations 86 for run 0

Estimated  Q = 0.743590 0.041179 0.215201 0.000010 0.000010 0.000010 best like -3783.578827 after 0 runs!
-> Dumping file: results/NA12874_1000G.qopt
```

</details>

## 6. Quantify uncertainty with bootstrap

The course exercise recommends bootstrap replicates when working with a single
sample, especially for low-coverage data. A simple run is:

```bash
./fastNGSadmix \
  -likes "$OUT.beagle.gz" \
  -fname "$REF" \
  -Nname "$NIND" \
  -out "${OUT}_boot100" \
  -whichPops all \
  -boot 100
```

This writes a new result set, including:

- `results/NA12874_1000G_boot100.qopt`
- `results/NA12874_1000G_boot100.log`

The bootstrap run gives replicate-based uncertainty around the admixture
proportions. Inspect the log together with the `.qopt` output when comparing
the single-run estimate and the bootstrap-supported result.

The bootstrap file has one point-estimate row followed by 100 bootstrap rows.

<details>
<summary>Verified command output</summary>

```text
The following number of bootstraps have been chosen: 100
Overlap: of 5181 sites between input and ref
...
At this bootstrapping: 100 out of: 100
CONVERGENCE!

Estimated  Q = 0.743585 0.041177 0.215208 0.000010 0.000010 0.000010 best like -3783.579243 after 0 runs!
-> Dumping file: results/NA12874_1000G_boot100.qopt
FIRST row of .qopt file is BEST estimated Q, rest are nBoot bootstrapping Qs
```

</details>

## 7. Plot the main estimate and bootstrap uncertainty

This repository includes a small plotting helper for the single-BAM tutorial:

```bash
Rscript scripts/plot_single_bam_admix.R \
  results/NA12874_1000G.qopt \
  results/NA12874_1000G_boot100.qopt \
  tutorial_figures/NA12874_1000G_admix.png \
  tutorial_figures/NA12874_1000G_bootstrap.png
```

This writes:

- `tutorial_figures/NA12874_1000G_admix.png`
- `tutorial_figures/NA12874_1000G_bootstrap.png`

Point estimate:

![Single-BAM fastNGSadmix estimate](tutorial_figures/NA12874_1000G_admix.png)

Point estimate with bootstrap intervals:

![Single-BAM fastNGSadmix bootstrap summary](tutorial_figures/NA12874_1000G_bootstrap.png)

## 8. What to inspect

After the workflow finishes, check:

- `results/NA12874_1000G.qopt` for the main ancestry estimate
- `results/NA12874_1000G.log` for optimization details
- `results/NA12874_1000G_boot100.qopt` for the bootstrap-supported estimate
- `results/NA12874_1000G_boot100.log` for the bootstrap run details
- `tutorial_figures/NA12874_1000G_admix.png` for the point-estimate barplot
- `tutorial_figures/NA12874_1000G_bootstrap.png` for the bootstrap uncertainty summary

## 9. Notes

- This tutorial intentionally skips PCA projection.
- The BAM-driven workflow here is for genotype likelihoods and admixture
  estimation with `fastNGSadmix`.
- The exact runtime depends on the machine, `ANGSD` build, and I/O speed.
