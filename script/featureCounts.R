#!/usr/bin/env Rscript

#======================#
#author : BioinfoCSM   #
#version : 1.0         #
#======================#

#===load packages===
library(argparser)
library (Rsubread)
library (limma)
library (edgeR)
library (stringr)

#===create parser===
parser <- arg_parser(description = "run featureCounts")
parser <- add_argument(parser, "--bam", help = "a character vector bam file", type = "character")
parser <- add_argument(parser, "--gtf", help = "gtf annotation file", type = "character")
parser <- add_argument(parser, "--featureType", help = "a character string or a vector of character strings giving the feature type or types used to select rows in the GTF annotation which will be used for read summarization", type = "character", default = "exon")
parser <- add_argument(parser, "--attrType", help = "a character string giving the attribute type in the GTF annotation which will be used to group features (eg. exons) into meta-features", type = "character", default = "gene_id")
parser <- add_argument(parser, "--isPairedEnd", help = "indicating whether libraries contain paired-end reads or not", type = "logical", default = TRUE)
parser <- add_argument(parser, "--strandSpecific", help = "0 (unstranded), 1 (stranded) and 2 (reversely stranded)", type = "numeric", default = 0)
parser <- add_argument(parser, "--outpre", help = "output prefix", type = "character")
parser <- add_argument (parser, "--thread", help = "number of thread", type
= "numeric")
args <- parse_args(parser)

#===featureCounts===
fCountsList = featureCounts(read.table (args$bam)[, 1], annot.ext=args$gtf, isGTFAnnotationFile=TRUE, nthreads=args$thread, GTF.featureType=args$featureType, GTF.attrType=args$attrType, isPairedEnd=args$isPairedEnd, strandSpecific=args$strandSpecific)
count <- fCountsList$counts
dgeList = DGEList(counts=fCountsList$counts, genes=fCountsList$annotation)
cpm = cpm(dgeList)

#===save files===
write.table(count, file = str_c (args$outpre, "/gene_count.xls"), 
	    sep="\t", col.names=T, row.names=T, quote=FALSE)
write.table (cpm, file = str_c (args$outpre, "/gene_cpm.xls"), 
sep = "\t", col.names = T, row.names = T, quote	= F)

#===sessionInfo===
sessionInfo()
