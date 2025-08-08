#!/usr/bin/env Rscript

#=======================#
#author = "BioinfoCSM"  #
#version = "1.0"        #
#=======================#

#===load packages===
library (argparser, quietly = T)
library (DESeq2, quietly = T)
library (tidyverse, quietly = T)
library (ggplot2)

#===create parser====
parser <- arg_parser(description = "analysis of difference expression")
parser <- add_argument(parser, "--gene_count", help = "gene count",
                       type = "character")
parser <- add_argument (parser, "--sample_info", help = "sample info", type = "character")
parser <- add_argument (parser, "--contrast", help = "contrast file", type = "character")
parser <- add_argument (parser, "--outpre", help = "output prefix", type = "character")
args <- parse_args(parser)

#===diff===
gene_count <- read.table (args$gene_count,
                          row.names = 1)
group <- read.table (args$sample_info)[, 1]
group <- factor (group, levels = c (unique(group)))
col_dat <- data.frame(row.names = colnames (gene_count), group = group) %>%
  dplyr::mutate (group = factor (group, levels = unique(group)))
contrast <- read.table (args$contrast) %>%
  dplyr::rename ("treat" = V1, "control" = V2) %>%
  dplyr::mutate (VS = str_c (treat, "_VS_", control))
dds <- DESeqDataSetFromMatrix(countData = gene_count,
                               colData = col_dat,
                               design = ~ group)
dds <- DESeq(dds)
for (mystr in contrast$VS) {
  lis = strsplit (mystr, "_VS_")
  temp <- results(dds, contrast = c("group", lis[[1]][1], lis[[1]][2]))
  temp <- temp[order(temp$padj), ]
  temp <- as.data.frame(temp)
  temp <- na.omit(temp)
  deg_sig <- mutate (temp, change = F)
  for (i in 1 : nrow (deg_sig)) {
    if (deg_sig[i, 2] > 1 && deg_sig[i, 6] < 0.05) {
      deg_sig[i, 7] <- "up"
    }
    else if (deg_sig[i, 2] < -1 && deg_sig[i, 6] < 0.05) {
      deg_sig[i, 7] <- "down"
    }
    else {
      deg_sig[i, 7] <- "stable"
    }
  }
  write.table (deg_sig, file = str_c (args$outpre, "/", lis[[1]][1], "_VS_",
                                      lis[[1]][2], ".xls"), quote = F,
               row.names = T, col.names = T)
  p <- ggplot(deg_sig, aes (log2FoldChange, -log10 (padj))) +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey") +
    geom_vline(xintercept = c (-1, 1), linetype = "dashed", color = "grey") +
    geom_point (aes (size = -log10(padj), color = -log10(padj))) +
    scale_color_gradientn (values = seq(0, 1, 0.2),
                           colors = c ("#39489F", "#39bbec", "#f9ed36", "#f38466", "#b81f25")) +
    scale_size_continuous(range = c (1, 10)) +
    theme_bw() +
    theme (panel.grid = element_blank(),
           legend.position = c (0.01, 0.7),
           legend.justification = c (0, 1)) +
    guides(size = "none")
  ggsave(filename = str_c (args$outpre, "/", lis[[1]][1], "_VS_",
                           lis[[1]][2], "_volcano.pdf"),
         plot = p, device = "pdf",
         width = 10, height = 10,
         units = "in")
}

#===sessionInfo===
sessionInfo()
