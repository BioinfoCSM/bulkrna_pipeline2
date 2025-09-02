#!/usr/bin/env python3
# coding=utf-8

__author__ = "BioinfoCSM"
__date__ = "2025-8-21"

import os
import argparse

parser = argparse.ArgumentParser (description = "help document")
parser.add_argument ("--use_singularity", action = "store_true", help = "If defined,run job within a singularity container", required = False)
parser.add_argument ("--use_apptainer", action = "store_true", help = "If defined,run job within a apptainer container", required = False)
parser.add_argument ("--use_conda", action = "store_true", help = "If defined,run job in a conda environment", required = False)
parser.add_argument ("--use_mamba", action = "store_true", help = "If defined,run job in a mamba environment", required = False)
parser.add_argument ("--mode", type = str, help = "Execute snakemake rule with local or cluster(currently,only slurm supported) environment", required = True, choices = ["local", "cluster"])
args = parser.parse_args ()

class all :
  def __init__ (self, use_singularity, use_conda, 
                use_apptainer, use_mamba, mode) : 
    self.use_singularity = use_singularity
    self.use_apptainer = use_apptainer
    self.use_conda = use_conda
    self.use_mamba = use_mamba
    self.mode = mode
  def get_template (self) : 

#===singularity + cluster===
    if self.use_singularity and self.mode == "cluster" : 
      os.system (f"cp {os.path.dirname (__file__)}/template/config_singularity_cluster.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_singularity_cluster {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_singularity_cluster.sh {os.path.dirname (__file__)}/submit.sh")

#===singularity + local===
    elif self.use_singularity and self.mode == "local" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_singularity_local.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_singularity_local {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_singularity_local.sh {os.path.dirname (__file__)}/submit.sh")

#===apptainer + cluster===
    if self.use_apptainer and self.mode == "cluster" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_singularity_cluster.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_singularity_cluster {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_singularity_cluster.sh {os.path.dirname (__file__)}/submit.sh && sed -i 's/--use-singularity/--use-apptainer/g' submit.sh")

#===apptainer + local===
    elif self.use_apptainer and self.mode == "local" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_singularity_local.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_singularity_local {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_singularity_local.sh {os.path.dirname (__file__)}/submit.sh && sed -i 's/--use-singularity/--use-apptainer/g' submit.sh")

#===conda + local===
    elif self.use_conda and self.mode == "local" : 
      os.system (f"cp {os.path.dirname (__file__)}/template/config_conda_local.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_conda_local {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_conda_local.sh {os.path.dirname (__file__)}/submit.sh")

#===mamba + local===
    elif self.use_mamba and self.mode == "local" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_conda_local.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_conda_local {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_conda_local.sh {os.path.dirname (__file__)}/submit.sh && sed -i 's/--conda-frontend conda/--conda-frontend mamba/g' submit.sh")

#===conda + cluster===
    elif self.use_conda and self.mode == "cluster" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_conda_cluster.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_conda_cluster {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_conda_cluster.sh {os.path.dirname (__file__)}/submit.sh")

#===mamba + cluster===
    elif self.use_mamba and self.mode == "cluster" :
      os.system (f"cp {os.path.dirname (__file__)}/template/config_conda_cluster.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_conda_cluster {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_conda_cluster.sh {os.path.dirname (__file__)}/submit.sh && sed -i 's/--conda-frontend conda/--conda-frontend mamba/g' submit.sh")

#===defaults conda + local===
    else : 
      os.system (f"cp {os.path.dirname (__file__)}/template/config_conda_local.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_conda_local {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_conda_local.sh {os.path.dirname (__file__)}/submit.sh")

if __name__ == "__main__" : 
  all (use_singularity = args.use_singularity, 
       use_apptainer = args.use_apptainer, 
       use_conda = args.use_conda, 
       use_mamba = args.use_mamba,
       mode = args.mode).get_template () 
