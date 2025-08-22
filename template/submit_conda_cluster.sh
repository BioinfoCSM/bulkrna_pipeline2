echo "===file check and running==="
if [ -e "envs/bulkrna_env" ] && [ -e "envs/rbase4_env" ] && [ -e "ref/genome.fa" ] && [ -e "ref/genes.gtf" ] ; then 
	echo start at `date` && \

	mkdir logs && \
	snakemake \
	--latency-wait 100 \
	--use-conda \
	--conda-frontend conda \
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
	--jobs 10 \
	-s Snakefile \
	1>snakemake.log 2>&1 && \

	echo complete at `date`
else 
	echo "error : bulkrna_env|rbase4_env|genome|gtf file no exist"
	echo """
you need to :
1.confirm whether the envs/bulkrna_env.yaml and envs/rbase4_env.yaml exists
2.copy : cp path/your_genome.fa ./ref/ && cp path/your_genes.gtf ./ref/
3.run again : nohup sh submit.sh 1>summit.log 2>&1 &"""
fi
