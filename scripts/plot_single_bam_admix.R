args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 4) {
  stop("Usage: Rscript scripts/plot_single_bam_admix.R <qopt> <boot_qopt> <out_main_png> <out_boot_png>")
}

qopt_file <- args[1]
boot_file <- args[2]
out_main <- args[3]
out_boot <- args[4]

read_qopt <- function(path) {
  lines <- readLines(path)
  if (length(lines) < 2) {
    stop(sprintf("File '%s' does not contain enough rows", path))
  }
  pops <- scan(text = lines[1], what = character(), quiet = TRUE)
  vals <- do.call(rbind, lapply(lines[-1], function(x) scan(text = x, what = numeric(), quiet = TRUE)))
  colnames(vals) <- pops
  vals
}

q_main <- read_qopt(qopt_file)
q_boot <- read_qopt(boot_file)

estimate <- as.numeric(q_main[1, ])
pops <- colnames(q_main)
boot_reps <- q_boot[-1, , drop = FALSE]

cols <- c("#355C7D", "#C06C84", "#F67280", "#6C5B7B", "#99B898", "#F8B195")
if (length(pops) > length(cols)) {
  cols <- rep(cols, length.out = length(pops))
}

png(out_main, width = 1100, height = 650)
par(mar = c(8, 4.5, 3, 1))
bp <- barplot(
  estimate,
  names.arg = pops,
  las = 2,
  col = cols[seq_along(pops)],
  ylim = c(0, 1),
  ylab = "Admixture proportion",
  main = "Single-BAM fastNGSadmix Estimate"
)
text(bp, estimate + 0.03, labels = sprintf("%.3f", estimate), xpd = NA, cex = 0.9)
box()
dev.off()

boot_q <- apply(boot_reps, 2, quantile, probs = c(0.025, 0.5, 0.975), na.rm = TRUE)

png(out_boot, width = 1100, height = 650)
par(mar = c(8, 4.5, 3, 1))
bp <- barplot(
  estimate,
  names.arg = pops,
  las = 2,
  col = cols[seq_along(pops)],
  ylim = c(0, 1),
  ylab = "Admixture proportion",
  main = "Single-BAM fastNGSadmix Estimate With Bootstrap Intervals"
)
nonzero_interval <- boot_q[1, ] != boot_q[3, ]
if (any(nonzero_interval)) {
  arrows(
    bp[nonzero_interval],
    boot_q[1, nonzero_interval],
    bp[nonzero_interval],
    boot_q[3, nonzero_interval],
    angle = 90,
    code = 3,
    length = 0.05,
    lwd = 2
  )
}
points(bp, boot_q[2, ], pch = 19, cex = 0.9)
text(bp, estimate + 0.03, labels = sprintf("%.3f", estimate), xpd = NA, cex = 0.9)
legend(
  "topright",
  legend = c("Point estimate", "Bootstrap median", "95% interval"),
  pch = c(15, 19, NA),
  lty = c(NA, NA, 1),
  col = c("black", "black", "black"),
  bty = "n"
)
box()
dev.off()

cat("Wrote:\n")
cat(out_main, "\n")
cat(out_boot, "\n")
