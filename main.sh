echo ===generate template=== && \

singularity exec image/bulkrna_v1.0.sif python get_template.py \
--singularity 0 \
--mode cluster && \

echo ===template done=== && \
echo """
you need to :
1.Modify "config.yaml" and "submit.sh" parameters according your requirement
2.Run command : 'nohup sh submit.sh 1>summit.log 2>&1 &'
"""
