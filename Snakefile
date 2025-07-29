#==========================#
#author : BioinfoCSM       #
#version : v1.0            #
#==========================#


#===import module===
import pandas as pd

#===config===
configfile : "config.yaml"


#===common===
raw_dir = config["raw_dir"]
work_dir = config["work_dir"]
SAMPLES = pd.read_csv (config["samples"], sep = "\t", header = None, usecols = [1]).squeeze ().tolist ()
CASE = pd.read_csv (config["contrasts"], sep = "\t", header = None, usecols = [0]).squeeze ().tolist ()
CTRL = pd.read_csv (config["contrasts"], sep = "\t", header = None, usecols = [1]).squeeze ().tolist ()

#===result===
rule all : 
  input : 
    expand (f"{work_dir}/ref/genome.hisat2.{{i}}.ht2", i = list (range (1, 9))),
    expand (f"{work_dir}/fastqc/{{sample}}/{{sample}}_1_fastqc.html", sample = SAMPLES),
    expand (f"{work_dir}/fastqc/{{sample}}/{{sample}}_2_fastqc.html", sample = SAMPLES),
    f"{work_dir}/quantification/pca_base_cpm.pdf",
    expand (f"{work_dir}/diff/{{case}}_VS_{{ctrl}}.xls", case = CASE, ctrl = CTRL),
    expand (f"{work_dir}/diff/{{case}}_VS_{{ctrl}}_volcano.pdf", case = CASE, ctrl = CTRL)

#===genome index===
rule genome_index : 
  input : 
    genome = config["genome_index"]["genome"]
  output : 
    expand (f"{work_dir}/ref/genome.hisat2.{{i}}.ht2", i = list (range (1, 9
)))
  params : 
    image = config["image"],
    thread = config["genome_index"]["thread"],
    prefix = f"{work_dir}/ref/genome.hisat2"
  shell : 
    """
    singularity exec {params.image} hisat2-build \
    -p {params.thread} {input.genome} {params.prefix}
    """

#===qc===
rule qc_fastqc : 
  input :
    r1 = f"{raw_dir}/{{sample}}_1.fastq.gz",
    r2 = f"{raw_dir}/{{sample}}_2.fastq.gz"
  output : 
    r1_html = f"{work_dir}/fastqc/{{sample}}/{{sample}}_1_fastqc.html",
    r2_html = f"{work_dir}/fastqc/{{sample}}/{{sample}}_2_fastqc.html"
  params :
    image = config ["image"],
    thread = config["qc"]["thread"],
    prefix = f"{work_dir}/fastqc/{{sample}}"
  shell :
    """
    singularity exec {params.image} fastqc \
    -f fastq \
    -t {params.thread} \
    {input.r1} \
    {input.r2} \
    -o {params.prefix}
    """


#===filter===
rule filter_fastp : 
  input : 
    r1 = f"{raw_dir}/{{sample}}_1.fastq.gz",
    r2 = f"{raw_dir}/{{sample}}_2.fastq.gz"
  output : 
    r1 = f"{work_dir}/cleandata/{{sample}}/{{sample}}_1.fastq.gz",
    r2 = f"{work_dir}/cleandata/{{sample}}/{{sample}}_2.fastq.gz",
    report = f"{work_dir}/cleandata/{{sample}}/{{sample}}.html",
    json = f"{work_dir}/cleandata/{{sample}}/{{sample}}.json"
  params : 
    image = config["image"],
    thread = config["filter"]["thread"],
    filter_stat_software = f"{work_dir}/script/filter_stat.py"
  shell :  
    """
    singularity exec {params.image} fastp \
        -w {params.thread} \
        -i {input.r1} \
        -I {input.r2} \
        -o {output.r1} \
        -O {output.r2} \
        -h {output.report} \
        -j {output.json} && \
    singularity exec {params.image} python {params.filter_stat_software}
    """


#===alignment===
rule align_hisat2 : 
  input : 
    r1 = f"{work_dir}/cleandata/{{sample}}/{{sample}}_1.fastq.gz", 
    r2 = f"{work_dir}/cleandata/{{sample}}/{{sample}}_2.fastq.gz", 
    index = expand (f"{work_dir}/ref/genome.hisat2.{{i}}.ht2", i = list (range (1, 9)))
  output : 
    sam = temp (f"{work_dir}/alignment/{{sample}}/{{sample}}.sam"),
    log = f"{work_dir}/alignment/{{sample}}/{{sample}}.log"
  params : 
    image = config["image"],
    strandness = config["alignment"]["strandness"],
    prefix = f"{work_dir}/ref/genome.hisat2",
    thread = config["alignment"]["thread"],
    alignment_stat_software = f"{work_dir}/script/alignment_stat.py"
  shell : 
    """
    singularity exec {params.image} hisat2 \
        -p {params.thread} \
        -x {params.prefix} \
        -1 {input.r1} \
        -2 {input.r2} \
        --new-summary --rna-strandness {params.strandness} \
        -S {output.sam} 2> {output.log} && \
    singularity exec {params.image} python {params.alignment_stat_software}
    """

rule sam2bam : 
  input : 
    sam = f"{work_dir}/alignment/{{sample}}/{{sample}}.sam"
  output : 
    bam = protected (f"{work_dir}/alignment/{{sample}}/{{sample}}.bam")
  params : 
    image = config["image"],
    thread = config["sam2bam"]["thread"]
  shell : 
    """
    singularity exec {params.image} samtools sort \
    -@ {params.thread} \
    -o {output.bam} \
    {input.sam} && \
    singularity exec {params.image} samtools index \
    -@ {params.thread} {output.bam}
    """


#===quantification===
rule quanti_featureCounts : 
  input : 
    bam_file = expand (f"{work_dir}/alignment/{{sample}}/{{sample}}.bam", sample = SAMPLES),
    gtf = config["genome_index"]["gtf"]
  output : 
    counts = f"{work_dir}/quantification/gene_count.xls",
    cpm = f"{work_dir}/quantification/gene_cpm.xls"
  params : 
    image = config["image"],
    featureCounts = f"{work_dir}/script/featureCounts.R",
    bam_list = f"{work_dir}/quantification/bam_list",
    feturetype = config["quanti"]["featuretype"],
    attritype = config["quanti"]["attritype"],
    ispairend = config["quanti"]["ispairend"],
    strandness = config["quanti"]["strandness"],
    thread = config["quanti"]["thread"],
    outpre = f"{work_dir}/quantification"
  shell : 
    """
    ls {input.bam_file} > {params.bam_list} && \
    singularity exec {params.image} Rscript \
    {params.featureCounts} -b {params.bam_list} \
    -g {input.gtf} -f {params.feturetype} \
    -a {params.attritype} -i {params.ispairend} \
    -s {params.strandness} -t {params.thread} -o {params.outpre} && \
    sed -i \'s/\.bam//g\' {output.counts} && \
    sed -i \'s/\.bam//g\' {output.cpm} && \
    rm {params.bam_list}
    """

rule pca_plot : 
  input : 
    cpm = f"{work_dir}/quantification/gene_cpm.xls",
    sample_info = config["samples"]
  output : 
    pca = f"{work_dir}/quantification/pca_base_cpm.pdf"
  params : 
    image = config["image"],
    outpre = f"{work_dir}/quantification",
    pca_software = f"{work_dir}/script/pca.R"
  shell : 
    """
    singularity exec {params.image} Rscript {params.pca_software} \
    --gene_cpm {input.cpm} --sample_info {input.sample_info} \
    --outpre {params.outpre}
    """


#===diff===
rule diff_deseq2 :
  input :
    counts = f"{work_dir}/quantification/gene_count.xls",
    sample_info = config["samples"],
    contrast = config["contrasts"]
  output :
    de_result = f"{work_dir}/diff/{{case}}_VS_{{ctrl}}.xls",
    volcano = f"{work_dir}/diff/{{case}}_VS_{{ctrl}}_volcano.pdf"
  params :
    image = config["image"],
    diff_software = f"{work_dir}/script/diff.R",
    outpre = f"{work_dir}/diff"
  shell :
    """
    singularity exec {params.image} Rscript {params.diff_software} \
    --gene_count {input.counts} \
    --sample_info {input.sample_info} \
    --contrast {input.contrast} \
    --outpre {params.outpre}
    """
