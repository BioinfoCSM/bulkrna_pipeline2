#!/usr/bin/env Rscript

#==========================#
#author : BioninfoCSM      #
#version : 1.0             #
#==========================#

#===load packages====
library (argparser, quietly = T)
library (tidyverse, quietly = T)
library(FactoMineR, quietly = T)
library(factoextra, quietly = T)
library (mixOmics, quietly = T)
library (ggplot2, quietly = T)

#===create parser====
parser <- arg_parser(description = "pca base on gene_cpm")
parser <- add_argument(parser, "--gene_cpm", help = "gene cpm normalized file", 
		       type = "character")
parser <- add_argument (parser, "--sample_info", help = "sample info", type = "character")
parser <- add_argument (parser, "--outpre", help = "output prefix", type = "character")
args <- parse_args(parser)

#===load data===
fildata <- read.table(args$gene_cpm, header = T, row.names = 1)
fildata_nor <- log2 (fildata + 1)
sample_info <- read.table (args$sample_info) %>% 
  dplyr::rename(c ("group" = V1, "sample" = V2))

#===plot===
pca_dat <- t (fildata_nor)
pca_dat <- PCA(pca_dat,graph = FALSE)
grouplist <- as.factor(sample_info[, "group"])
p <- fviz_pca_ind(pca_dat, 
             ind="point", 
             col.ind=grouplist, 
             show.legend=FALSE, 
             legend.title="Groups", 
             addEllipses = T)

#===save file===
ggsave (filename = str_c (args$outpre, "/pca_base_cpm.pdf"), 
        plot = p, 
        width = 6, 
        height = 6)

#===sessionInfo===
sessionInfo()
