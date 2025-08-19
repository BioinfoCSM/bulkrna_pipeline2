echo ===start generate template=== && \

python get_template.py \
--use_conda \
--mode local && \

echo ===template done=== && \
echo """
you need to :
1.Modify "config.yaml" and "submit.sh" parameters according your requirement
2.Run command : 'nohup sh submit.sh 1>submit.log 2>&1 &'
"""
