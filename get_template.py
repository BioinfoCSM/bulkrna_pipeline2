#!/usr/bin/env python3
# coding=utf-8

__author__ = "BioinfoCSM"
__version__ = "0.1"

import os
import argparse

parser = argparse.ArgumentParser (description = "It is a python program for generate template of bulkrna-seq pipeline")
parser.add_argument ("--singularity", type = int, help = "use singularity or not,0 means 'no',1 means 'yes'", required = False, default = True, choices = [0, 1])
parser.add_argument ("--mode", type = str, help = "Execute snakemake rule with local or cluster mode", required = False, default = "cluster", choices = ["local", "cluster"])
args = parser.parse_args ()

class all :
  def __init__ (self, singularity, mode) : 
    self.singularity = singularity
    self.mode = mode
  def get_template (self) : 
    if self.singularity == 0 and self.mode == "cluster": 
      os.system (f"cp {os.path.dirname (__file__)}/template/config_singularity_cluster.yaml {os.path.dirname (__file__)}/config.yaml")
      os.system (f"cp {os.path.dirname (__file__)}/template/Snakefile_singularity_cluster {os.path.dirname (__file__)}/Snakefile")
      os.system (f"cp {os.path.dirname (__file__)}/template/submit_singularity_cluster.sh {os.path.dirname (__file__)}/submit.sh")
    else : 
      print ("updating...")


if __name__ == "__main__" : 
  all (singularity = args.singularity, mode = args.mode).get_template () 
