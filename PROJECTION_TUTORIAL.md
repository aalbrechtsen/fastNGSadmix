# fastNGSadmix Projection Tutorial

This tutorial focuses on projection of a new sample onto PCs defined by a
reference panel.

In this repository, the working example is projection of the single-sample
PLINK prefix `example/NA20502_TSI` onto the reference panel
`data/humanOrigins_7worldPops`.

## 1. Build the program

From the repository root:

```bash
make
```

For the PCA plotting script, install `BEDMatrix` in R:

```r
install.packages("BEDMatrix")
```

## 2. Prepare the example data

If you do not already have the example files locally:

```bash
mkdir -p data
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/data.tar.gz
wget -P data https://www.popgen.dk/software/download/fastNGSadmix/example.tar.gz
tar -xzf data/data.tar.gz
tar -xzf data/example.tar.gz
mkdir -p results
```

This gives you:

- reference panel prefix: `data/humanOrigins_7worldPops`
- projected sample prefix: `example/NA20502_TSI`

## 3. Estimate admixture proportions for the projected sample

Set the shared inputs:

```bash
PLINKFILE=example/NA20502_TSI
REF=data/refPanel_humanOrigins_7worldPops.txt
NIND=data/nInd_humanOrigins_7worldPops.txt
```

Run `fastNGSadmix`:

```bash
./fastNGSadmix -plink "$PLINKFILE" -fname "$REF" -Nname "$NIND" -out results/NA20502_TSI -whichPops French,Han,Yoruba
```

Expected result:

- `results/NA20502_TSI.qopt`
- `results/NA20502_TSI.log`

For this example, the estimated admixture proportions are essentially 100%
French:

```text
French Han Yoruba
1.0000 0.0000 0.0000
```

## 4. Project the sample onto the reference PCs

Run the PCA/projection script:

```bash
Rscript R/fastNGSadmixPCA.R -plinkFile "$PLINKFILE" -qopt results/NA20502_TSI.qopt -out results/NA20502_TSI -ref data/humanOrigins_7worldPops
```

This writes:

- `results/NA20502_TSI_covar.txt`
- `results/NA20502_TSI_indi.txt`
- `results/NA20502_TSI_eigenvecs.txt`
- `results/NA20502_TSI_eigenvals.txt`
- `results/NA20502_TSI_admixBarplot.png`
- `results/NA20502_TSI_PCAplot.pdf`

The script also prints the reference populations used and the output file names.

## 5. Embedded example figures

Admixture barplot:

![Admixture barplot for NA20502_TSI](tutorial_figures/NA20502_TSI_bedmatrix_admixBarplot.png)

Projected PCA position:

![PCA projection for NA20502_TSI](tutorial_figures/NA20502_TSI_bedmatrix_PCAplot.png)

The corrected projection places `NA20502_TSI` inside the French cluster, which
is consistent with the `.qopt` estimate.

## 6. PCAone projection

The raw example prefixes are not directly compatible for `PCAone` projection:

- reference sites: `442769`
- projected sample sites: `441702`

So the first step is to harmonize both PLINK prefixes to the same site set and
allele orientation.

### 6.1 Harmonize the PLINK prefixes

```bash
python3 scripts/harmonize_plink_for_pcaone.py \
  --ref data/humanOrigins_7worldPops \
  --sample example/NA20502_TSI \
  --outdir results/pcaone_harmonized
```

This writes:

- `results/pcaone_harmonized/ref.bed`
- `results/pcaone_harmonized/ref.bim`
- `results/pcaone_harmonized/ref.fam`
- `results/pcaone_harmonized/sample.bed`
- `results/pcaone_harmonized/sample.bim`
- `results/pcaone_harmonized/sample.fam`

### 6.2 Download PCAone if needed

```bash
pkg=https://github.com/Zilong-Li/PCAone/releases/latest/download/PCAone-Linux.zip
wget "$pkg" || curl -LO "$pkg"
unzip -o PCAone-Linux.zip
chmod +x PCAone
```

### 6.3 Run PCAone on the harmonized reference

```bash
./PCAone -b results/pcaone_harmonized/ref -k 10 --printv -o results/pcaone_harmonized/ref_pcaone
```

This writes:

- `results/pcaone_harmonized/ref_pcaone.eigvals`
- `results/pcaone_harmonized/ref_pcaone.eigvecs`
- `results/pcaone_harmonized/ref_pcaone.eigvecs2`
- `results/pcaone_harmonized/ref_pcaone.loadings`
- `results/pcaone_harmonized/ref_pcaone.mbim`
- `results/pcaone_harmonized/ref_pcaone.sigvals`

### 6.4 Compute and plot the projected sample from the PCAone reference decomposition

`PCAone` currently crashes on this single-sample projection in this environment,
even after harmonization, so the projected coordinates are computed from the
saved `PCAone` loadings and singular values and then plotted together with the
reference PCs.

```bash
Rscript scripts/plot_pcaone_projection.R \
  results/pcaone_harmonized/sample \
  results/pcaone_harmonized/ref_pcaone \
  tutorial_figures/NA20502_TSI_pcaone_projection.png \
  results/pcaone_harmonized/sample_pcaone_projection.tsv
```

This writes:

- `tutorial_figures/NA20502_TSI_pcaone_projection.png`
- `results/pcaone_harmonized/sample_pcaone_projection.tsv`

Embedded PCAone projection plot:

![PCAone projection for NA20502_TSI](tutorial_figures/NA20502_TSI_pcaone_projection.png)
