echo start at `date` && \

#===set total core for this pipeline===
total_core=20

#===get config file===
#you need to set parameters according your requirements
singularity exec image/BulkRNA.sif python script/config.py \
--raw_dir path/BulkRNA_pipeline/rawdata \
--work_dir path/BulkRNA_pipeline \
--sample_info path/BulkRNA_pipeline/samples.txt \
--contrasts path/BulkRNA_pipeline/contrasts.txt \
--genome_index_thread 2 \
--qc_thread 2 \
--filter_thread 2 \
--hisat2_strandness F \
--alignment_thread 4 \
--sam2bam_thread 4 \
--gtf_featuretype exon \
--gtf_attrtype gene_id \
--ispairend TRUE \
--featurecount_strandness 0 \
--quanti_thread 2 && \

echo config file completed! && \

#===run snakefile===
echo "check your file and running snakemake!"
if [ -e "image/BulkRNA.sif" ] && [ -e "ref/genome.fa" ] && [ -e "ref/genes.gtf" ] ; then 
	snakemake -c ${total_core} -s Snakefile 1>snakemake.log 2>&1 && \
	echo complete at `date`
else 
	echo "error : image|genome|gtf file no exist"
fi
