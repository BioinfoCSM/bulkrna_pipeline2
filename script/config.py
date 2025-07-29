#!/usr/bin/env python
# coding=utf-8

__author__ = "BioinfoCSM"
__version__ = "1.0"

import os
import argparse

parser = argparse.ArgumentParser (description = "help document")
parser.add_argument ("--raw_dir", type = str, help = "rawdata directory", required = True)
parser.add_argument ("--work_dir", type = str, help = "work directory", required = True)
parser.add_argument ("--sample_info", type = str, help = "input sample_info file, col1 is group name,col2 is sample name", required = True)
parser.add_argument ("--contrasts", type = str, help = "input contrasts file for difference expression, col1 is case,col2 is control", required = True)
parser.add_argument ("--genome_index_thread", type = int, help = "number of thread for building reference genome index", required = False, default = 2)
parser.add_argument ("--qc_thread", type = int, help = "number of thread for fastqc", required = False, default = 2)
parser.add_argument ("--filter_thread", type = int, help = "number of thread for fastq trim", required = False, default = 2)
parser.add_argument ("--hisat2_strandness", type = str, help = "specify strand-specific information (unstranded)", required = False, default = "F", choices = ["F", "RF", "FR"])
parser.add_argument ("--alignment_thread", type = int, help = "number of thread for alignment", required = False, default = 4)
parser.add_argument ("--sam2bam_thread", type = int, help = "number of thread for sam to bam base on samtools", required = False, default = 4)
parser.add_argument ("--gtf_featuretype", type = str, help = "a character string or a vector of character strings giving the feature type or types used to select rows in the GTF annotation which will be used for read summarization. 'exon' by default. This argument is only applicable when isGTFAnnotationFile is TRUE. Feature types can be found in the third column of a GTF annotation.", required = False, default = "exon")
parser.add_argument ("--gtf_attrtype", type = str, help = "a character string giving the attribute type in the GTF annotation which will be used to group features (eg. exons) into meta-features (eg. genes). 'gene_id' by default. This argument is only applicable when isGTFAnnotationFile is TRUE. Attributes can be found in the ninth column of a GTF annotation.", required = False, default = "gene_id")
parser.add_argument ("--ispairend", type = str, help = "A logical scalar or a logical vector, indicating whether libraries contain paired-end reads or not. True by default. For any library that contains paired-end reads, the 'countReadPairs' parameter controls if read pairs or reads should be counted.", required = False, default = "TRUE")
parser.add_argument ("--featurecount_strandness", type = int, help = "an integer vector indicating if strand-specific read counting should be performed. Length of the vector should be either 1 (meaning that the value is applied to all input files), or equal to the total number of input files provided. Each vector element should have one of the following three values: 0 (unstranded), 1 (stranded) and 2 (reversely stranded). Default value of this parameter is 0 (ie. unstranded read counting is performed for all input files).", required = False, default = 0)
parser.add_argument ("--quanti_thread", type = int, help = "number of thread for calculate gene count", required = False, default = 2)
args = parser.parse_args ()

class all : 

    def __init__ (self, raw_dir, work_dir, sample_info, contrasts, genome_index_thread, qc_thread, filter_thread, hisat2_strandness, alignment_thread, sam2bam_thread, gtf_featuretype, gtf_attrtype, ispairend, featurecount_strandness, quanti_thread) : 
        self.raw_dir = raw_dir
        self.work_dir = work_dir
        self.sample_info = sample_info
        self.contrasts = contrasts
        self.genome_index_thread = genome_index_thread
        self.qc_thread = qc_thread
        self.filter_thread = filter_thread
        self.hisat2_strandness = hisat2_strandness
        self.alignment_thread = alignment_thread
        self.sam2bam_thread = sam2bam_thread
        self.gtf_featuretype = gtf_featuretype
        self.gtf_attrtype = gtf_attrtype
        self.ispairend = ispairend
        self.featurecount_strandness = featurecount_strandness
        self.quanti_thread = quanti_thread

    def config (self) : 
        fw = open (f"{os.path.dirname (__file__)}/../config.yaml", "w")
        shell = f"""#===common params===
raw_dir : "{self.raw_dir}"
work_dir : "{self.work_dir}"
image : "{os.path.dirname (__file__)}/../image/BulkRNA.sif"
samples : "{self.sample_info}"
contrasts : "{self.contrasts}"

#===genome index===
genome_index :
  genome : "{os.path.dirname (__file__)}/../ref/genome.fa" 
  gtf : "{os.path.dirname (__file__)}/../ref/genes.gtf"
  thread : {self.genome_index_thread}

#===qc params===
qc :
  thread : {self.qc_thread}

#===filter params===
filter :
  thread : {self.filter_thread}

#===alignment params===
alignment :
  strandness : "{self.hisat2_strandness}"
  thread : {self.alignment_thread}
sam2bam : 
  thread : {self.sam2bam_thread}

#===quantification===
quanti :
  featuretype : "{self.gtf_featuretype}"
  attritype : "{self.gtf_attrtype}"
  ispairend : "{self.ispairend}"
  strandness : {self.featurecount_strandness}
  thread : {self.quanti_thread}
        """
        fw.write (shell + "\n")

if __name__ == "__main__" : 
    all (raw_dir = args.raw_dir, work_dir = args.work_dir, sample_info = args.sample_info, contrasts = args.contrasts, genome_index_thread = args.genome_index_thread, qc_thread = args.qc_thread, filter_thread = args.filter_thread, hisat2_strandness = args.hisat2_strandness, alignment_thread = args.alignment_thread, sam2bam_thread = args.sam2bam_thread, gtf_featuretype = args.gtf_featuretype, gtf_attrtype = args.gtf_attrtype, ispairend = args.ispairend, featurecount_strandness = args.featurecount_strandness, quanti_thread = args.quanti_thread).config ()
