#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 4) {
  stop("Usage: Rscript scripts/plot_pcaone_projection.R <harmonized-sample-prefix> <ref-pcaone-prefix> <out.png> <out.tsv>")
}

suppressPackageStartupMessages(library(BEDMatrix))

sample_prefix <- args[1]
ref_prefix <- args[2]
out_png <- args[3]
out_tsv <- args[4]

ref <- read.table(paste0(ref_prefix, ".eigvecs2"), as.is = TRUE, comment.char = "#")
colnames(ref) <- c("FID", "IID", paste0("PC", seq_len(ncol(ref) - 2)))

mbim <- read.table(paste0(ref_prefix, ".mbim"), as.is = TRUE)
loadings <- as.matrix(read.table(paste0(ref_prefix, ".loadings")))
sigvals <- scan(paste0(ref_prefix, ".sigvals"), comment.char = "#", quiet = TRUE)

sample_fam <- read.table(paste0(sample_prefix, ".fam"), as.is = TRUE)
sample_bed <- BEDMatrix(sample_prefix, simple_names = TRUE)
sample_geno <- as.numeric(as.matrix(sample_bed[1,,drop = FALSE]))

p <- mbim[, 7]
geno_sd <- sqrt(2 * p * (1 - p))
sample_geno[is.na(sample_geno)] <- 2 * p[is.na(sample_geno)]
sample_std <- (sample_geno - 2 * p) / geno_sd
sample_pc <- as.numeric(sample_std %*% loadings[, 1:2, drop = FALSE] / (2 * sigvals[1:2]))

sample <- data.frame(
  FID = sample_fam[1, 1],
  IID = sample_fam[1, 2],
  PC1 = sample_pc[1],
  PC2 = sample_pc[2],
  stringsAsFactors = FALSE
)

write.table(sample, out_tsv, quote = FALSE, sep = "\t", row.names = FALSE)

cols <- as.integer(as.factor(ref$FID))

png(out_png, width = 2100, height = 2100, res = 300)
par(mar = c(5, 4, 4, 8) + 0.1)
plot(ref$PC1, ref$PC2,
     xlab = "PC1",
     ylab = "PC2",
     col = cols,
     pch = 16)
points(sample$PC1, sample$PC2, pch = 4, cex = 2, lwd = 4)
par(xpd = TRUE)
legend("topright", inset = c(-0.28, 0), legend = unique(ref$FID), fill = unique(cols))
dev.off()
