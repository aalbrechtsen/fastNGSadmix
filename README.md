# fastNGSadmix

Program for infering admixture proportions and doing PCA with a single NGS sample. Inferences based on reference panel.

For how to use program go to:
http://www.popgen.dk/software/index.php/FastNGSadmix

The program has been published in Bioinformatics:

Emil Jørsboe, Kristian Hanghøj, Anders Albrechtsen;
fastNGSadmix: Admixture proportions and principal component analysis of a single NGS sample,
Bioinformatics, btx474, https://doi.org/10.1093/bioinformatics/btx474

Installation:
=====

git clone https://github.com/e-jorsboe/fastNGSadmix.git;

cd fastNGSadmix; make

For the R files the BEDMatrix package is required, it can be obtained thus:

install.packages("BEDMatrix")

It has been tested for R version 3.2.x and later.

The R scripts and the C++ program has been tested on a 8 GB linux system,
however if one wants to create larger reference panels (and thereby genotypes),
doing it on a server with more RAM would be advisable.
As the R scripts will take up a lot of RAM in that case.

Example data:
=====

The project website provides runnable example archives:

- `https://www.popgen.dk/software/download/fastNGSadmix/data.tar.gz`
- `https://www.popgen.dk/software/download/fastNGSadmix/example.tar.gz`
- `https://www.popgen.dk/software/download/fastNGSadmix/data1000genomes.tar.gz`

The `data.tar.gz` and `example.tar.gz` archives match the basic quick-start
workflow from the project website. The `data1000genomes.tar.gz` archive
contains the larger 1000 Genomes reference panel used in the BAM-based
example.

For a runnable walkthrough using the hosted example data, see
[EXAMPLE_DATA_TUTORIAL.md](/home/albrecht/github/fastNGSadmix/EXAMPLE_DATA_TUTORIAL.md).
