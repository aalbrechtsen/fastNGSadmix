#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 4) {
  stop("Usage: Rscript scripts/plot_pcaone_direct_projection.R <ref.eigvecs2> <sample.eigvecs> <out.png> <sample-label>")
}

ref_file <- args[1]
sample_file <- args[2]
out_file <- args[3]
sample_label <- args[4]

ref <- read.table(ref_file, as.is = TRUE, comment.char = "#")
colnames(ref) <- c("FID", "IID", paste0("PC", seq_len(ncol(ref) - 2)))

sample <- read.table(sample_file, as.is = TRUE)
sample_df <- data.frame(
  FID = "SAMPLE",
  IID = sample_label,
  PC1 = as.numeric(sample[1, 1]),
  PC2 = as.numeric(sample[1, 2]),
  stringsAsFactors = FALSE
)

cols <- as.integer(as.factor(ref$FID))

png(out_file, width = 2100, height = 2100, res = 300)
par(mar = c(5, 4, 4, 8) + 0.1)
plot(ref$PC1, ref$PC2,
     xlab = "PC1",
     ylab = "PC2",
     col = cols,
     pch = 16)
points(sample_df$PC1, sample_df$PC2, pch = 4, cex = 2, lwd = 4)
par(xpd = TRUE)
legend("topright", inset = c(-0.28, 0), legend = unique(ref$FID), fill = unique(cols))
dev.off()
