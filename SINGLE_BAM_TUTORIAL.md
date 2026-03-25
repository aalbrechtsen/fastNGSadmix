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

To plot the point estimate:

```bash
Rscript scripts/plot_single_bam_admix.R \
  results/NA12874_1000G.qopt \
  results/NA12874_1000G_boot100.qopt \
  tutorial_figures/NA12874_1000G_admix.png \
  tutorial_figures/NA12874_1000G_bootstrap.png
```

Point estimate:

![Single-BAM fastNGSadmix estimate](tutorial_figures/NA12874_1000G_admix.png)

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

The same plotting command above also writes the bootstrap summary figure:

- `tutorial_figures/NA12874_1000G_bootstrap.png`

Bootstrap uncertainty summary:

![Single-BAM fastNGSadmix bootstrap summary](tutorial_figures/NA12874_1000G_bootstrap.png)

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

## 7. Run PCAone on the 1000G reference panel

This step requires a `PCAone` binary with `--beagle` support available as
`./PCAone`.

Run PCA on the same 1000 Genomes reference panel used above:

```bash
mkdir -p results/pcaone_1000g
./PCAone -b data1000genomes/1000genomesRefPanel -k 10 --printv -o results/pcaone_1000g/ref
```

This writes:

- `results/pcaone_1000g/ref.eigvals`
- `results/pcaone_1000g/ref.eigvecs`
- `results/pcaone_1000g/ref.eigvecs2`
- `results/pcaone_1000g/ref.loadings`
- `results/pcaone_1000g/ref.mbim`
- `results/pcaone_1000g/ref.sigvals`

<details>
<summary>Verified command output</summary>

```text
[25/03/2026-08:30:32] start parsing PLINK format
[25/03/2026-08:30:32] N (# samples): 120, M (# SNPs): 6676750
...
[25/03/2026-08:32:19] stops at epoch =  7
[25/03/2026-08:32:20] save matched sites in .mbim file and permutation mode is  1
[25/03/2026-08:32:33] eigen vectors and values saved
```

</details>

## 8. Project the BAM-derived beagle file with `PCAone`

Project the exact beagle file produced by `ANGSD` in step 4:

```bash
./PCAone \
  --beagle results/NA12874_1000G.beagle.gz \
  --USV results/pcaone_1000g/ref \
  --project 2 \
  -o results/pcaone_1000g/NA12874_from_bam
```

This writes:

- `results/pcaone_1000g/NA12874_from_bam.eigvecs`
- `results/pcaone_1000g/NA12874_from_bam.eigvals`
- `results/pcaone_1000g/NA12874_from_bam.sigvals`
- `results/pcaone_1000g/NA12874_from_bam.log`

For the tested run, the projection summary was:

- overlap: `5181`
- flipped: `0`
- skipped: `0`

Projected coordinates start with:

```text
PC1      PC2      PC3
-0.0271  -0.0782  -0.0357
```

<details>
<summary>Verified command output</summary>

```text
[25/03/2026-08:40:43] start parsing BEAGLE format
[25/03/2026-08:40:43] N (# samples):  1, M (# SNPs): 5181
[25/03/2026-08:40:54] projection overlap = 5181, flipped =  0, skipped =  0
[25/03/2026-08:41:02] eigen vectors and values saved
```

</details>

## 9. Plot the projected sample

Use the existing plotting helper to overlay the projected sample on the
reference PCs:

```bash
Rscript scripts/plot_pcaone_direct_projection.R \
  results/pcaone_1000g/ref.eigvecs2 \
  results/pcaone_1000g/NA12874_from_bam.eigvecs \
  tutorial_figures/NA12874_from_bam_pcaone_projection.png \
  NA12874
```

This writes:

- `tutorial_figures/NA12874_from_bam_pcaone_projection.png`

Projected sample on the 1000G PCA:

![PCAone projection for NA12874 from BAM-derived beagle](tutorial_figures/NA12874_from_bam_pcaone_projection.png)

## 10. What to inspect

After the workflow finishes, check:

- `results/NA12874_1000G.qopt` for the main ancestry estimate
- `results/NA12874_1000G.log` for optimization details
- `results/NA12874_1000G_boot100.qopt` for the bootstrap-supported estimate
- `results/NA12874_1000G_boot100.log` for the bootstrap run details
- `results/pcaone_1000g/ref.eigvecs2` for the reference PCA coordinates
- `results/pcaone_1000g/NA12874_from_bam.eigvecs` for the projected sample coordinates
- `tutorial_figures/NA12874_from_bam_pcaone_projection.png` for the PCAone projection figure
- `tutorial_figures/NA12874_1000G_admix.png` for the point-estimate barplot
- `tutorial_figures/NA12874_1000G_bootstrap.png` for the bootstrap uncertainty summary

## 11. Notes

- The BAM-driven workflow here is for genotype likelihoods and admixture
  estimation with `fastNGSadmix`, plus direct PCA projection from the resulting
  beagle file when using a `PCAone` build that supports `--beagle`.
- The exact runtime depends on the machine, `ANGSD` build, and I/O speed.
