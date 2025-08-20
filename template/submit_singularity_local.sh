echo "===file check and running==="
if [ -e "image/bulkrna_v1.0.sif" ] && [ -e "ref/genome.fa" ] && [ -e "ref/genes.gtf" ] ; then 
	echo start at `date` && \

	snakemake \
	--use-singularity \
	-c 10 \
	-s Snakefile \
	1>snakemake.log 2>&1 && \

	echo complete at `date`
else 
	echo "error : image|genome|gtf file no exist"
	echo """
you need to :
1.confirm whether the image/bulkrna_v1.0.sif exists
2.copy : cp path/your_genome.fa ./ref/ && cp path/your_genes.gtf ./ref/
3.run again : nohup sh submit.sh 1>summit.log 2>&1 &"""
fi
