echo "===file check and running==="
if [ -e "image/BulkRNA.sif" ] && [ -e "ref/genome.fa" ] && [ -e "ref/genes.gtf" ] ; then 
	echo start at `date` && \
	mkdir logs && \
	snakemake \
	--latency-wait 100 \
	--use-singularity \
	--cluster \
	"sbatch \
	--job-name={rule} \
	--partition=cpu \
	--nodes=1 \
	--ntasks-per-node=1 \
	--cpus-per-task={threads} \
	--mem={resources.mem_gb}G \
	--error=logs/{rule}_%j.err \
	--output=logs/{rule}_%j.out" \
	-F \
        --until \
        --ri \
        --keep-going \
	--jobs 100 \
	-s Snakefile \
1>snakemake.log 2>&1 && \

echo complete at `date`
else 
	echo "error : image|genome|gtf file no exist"
	echo """
you need to :
1.pull image : singularity pull --arch amd64 library://bioinfocsm/share/bulkrna:v1.0
2.run command : 'cp path/your_genome.fa' ./ref/ && cp path/your_genes.gtf ./ref/"""
fi
