# fastNGSadmix Example Data Tutorial

This tutorial uses the example archives linked from the fastNGSadmix project
page:

- `https://www.popgen.dk/software/index.php/FastNGSadmix`
- `https://www.popgen.dk/software/download/fastNGSadmix/data.tar.gz`
- `https://www.popgen.dk/software/download/fastNGSadmix/example.tar.gz`

The steps below build the program, download the hosted example data, estimate
admixture proportions from both genotype likelihoods and a single-individual
PLINK file, and then run PCA for each case.

## 1. Build fastNGSadmix

From the repository root:

```bash
make
```

If you want to run the PCA examples, install the R package used by the scripts:

```r
install.packages("BEDMatrix")
```

## 2. Download the example archives into `data/`

Run these commands from the repository root:

```bash
mkdir -p data
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/data.tar.gz
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/example.tar.gz
tar -xzf data/data.tar.gz
tar -xzf data/example.tar.gz
```

The downloaded archives are stored in `data/`, while unpacking from the
repository root creates the working directories `data/` and `example/`.

## 3. Run the genotype-likelihood example

Set the input and reference paths:

```bash
mkdir -p results
GL=example/yriFrenchHan_depth05.beagle.gz
REF=data/refPanel_humanOrigins_7worldPops.txt
NIND=data/nInd_humanOrigins_7worldPops.txt
```

Estimate admixture proportions:

```bash
./fastNGSadmix -likes "$GL" -fname "$REF" -Nname "$NIND" -out results/yriFrenchHan_depth05 -whichPops French,Han,Yoruba
```

This writes:

- `results/yriFrenchHan_depth05.qopt`
- `results/yriFrenchHan_depth05.log`

Run PCA using the estimated admixture proportions:

```bash
Rscript R/fastNGSadmixPCA.R -likes "$GL" -qopt results/yriFrenchHan_depth05.qopt -out results/yriFrenchHan_depth05 -ref data/humanOrigins_7worldPops
```

Generated example outputs from the BEDMatrix-backed test run in this repo:

- Admixture barplot: [tutorial_figures/yriFrenchHan_depth05_bedmatrix_admixBarplot.png](/home/albrecht/github/fastNGSadmix/tutorial_figures/yriFrenchHan_depth05_bedmatrix_admixBarplot.png)
- PCA plot PDF: [tutorial_figures/yriFrenchHan_depth05_bedmatrix_PCAplot.pdf](/home/albrecht/github/fastNGSadmix/tutorial_figures/yriFrenchHan_depth05_bedmatrix_PCAplot.pdf)
- PCA plot PNG: [tutorial_figures/yriFrenchHan_depth05_bedmatrix_PCAplot.png](/home/albrecht/github/fastNGSadmix/tutorial_figures/yriFrenchHan_depth05_bedmatrix_PCAplot.png)
- Covariance matrix: [results/yriFrenchHan_depth05_bedmatrix_covar.txt](/home/albrecht/github/fastNGSadmix/results/yriFrenchHan_depth05_bedmatrix_covar.txt)
- Eigenvectors: [results/yriFrenchHan_depth05_bedmatrix_eigenvecs.txt](/home/albrecht/github/fastNGSadmix/results/yriFrenchHan_depth05_bedmatrix_eigenvecs.txt)

![Admixture barplot for yriFrenchHan_depth05](/home/albrecht/github/fastNGSadmix/tutorial_figures/yriFrenchHan_depth05_bedmatrix_admixBarplot.png)

![PCA plot for yriFrenchHan_depth05](/home/albrecht/github/fastNGSadmix/tutorial_figures/yriFrenchHan_depth05_bedmatrix_PCAplot.png)

## 4. Run the PLINK example

Set the PLINK input prefix:

```bash
PLINKFILE=example/NA20502_TSI
```

Estimate admixture proportions:

```bash
./fastNGSadmix -plink "$PLINKFILE" -fname "$REF" -Nname "$NIND" -out results/NA20502_TSI -whichPops French,Han,Yoruba
```

This writes:

- `results/NA20502_TSI.qopt`
- `results/NA20502_TSI.log`

Run PCA:

```bash
Rscript R/fastNGSadmixPCA.R -plinkFile "$PLINKFILE" -qopt results/NA20502_TSI.qopt -out results/NA20502_TSI -ref data/humanOrigins_7worldPops
```

Generated example outputs from the BEDMatrix-backed test run in this repo:

- Admixture barplot: [tutorial_figures/NA20502_TSI_bedmatrix_admixBarplot.png](/home/albrecht/github/fastNGSadmix/tutorial_figures/NA20502_TSI_bedmatrix_admixBarplot.png)
- PCA plot PDF: [tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.pdf](/home/albrecht/github/fastNGSadmix/tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.pdf)
- PCA plot PNG: [tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.png](/home/albrecht/github/fastNGSadmix/tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.png)
- Covariance matrix: [results/NA20502_TSI_bedmatrix_covar.txt](/home/albrecht/github/fastNGSadmix/results/NA20502_TSI_bedmatrix_covar.txt)
- Eigenvectors: [results/NA20502_TSI_bedmatrix_eigenvecs.txt](/home/albrecht/github/fastNGSadmix/results/NA20502_TSI_bedmatrix_eigenvecs.txt)

![Admixture barplot for NA20502_TSI](/home/albrecht/github/fastNGSadmix/tutorial_figures/NA20502_TSI_bedmatrix_admixBarplot.png)

![PCA plot for NA20502_TSI](/home/albrecht/github/fastNGSadmix/tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.png)

## 5. Optional: 1000 Genomes reference panel example

The project page also documents a larger example that uses a BAM file plus a
1000 Genomes-based reference panel. Download the extra archive if you want to
run that workflow:

```bash
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/data1000genomes.tar.gz
tar -xzf data/data1000genomes.tar.gz
```

The website quick start uses:

```bash
BAM=example/smallNA12874.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
REF=data1000genomes/refPanel_1000genomesRefPanel.txt
SITES=data1000genomes/1000genomesRefPanel.sites
NIND=data1000genomes/nInd_1000genomesRefPanel.txt
GENO=data1000genomes/1000genomesRefPanel
```

You first generate genotype likelihoods with ANGSD, then run fastNGSadmix and
the PCA script on the resulting `.beagle.gz` file.

## 6. Notes

- The example commands above are taken from the project website and adapted to
  run from the repository root with archives stored under `data/`.
- The PCA steps can use substantial RAM, especially with larger reference
  panels.
- Running `./fastNGSadmix` with no arguments prints the full option list.
