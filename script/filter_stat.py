#!/usr/bin/env python
# coding=utf-8

__author__ = "BioinfoCSM"
__version__ = "1.0"

import os
import json
import argparse

parser = argparse.ArgumentParser (description = f"python {__file__}")
parser.parse_args ()

def filter_stat () : 
    fw = open (f"{os.path.dirname (__file__)}/../cleandata/filter_stat.xls", "w", encoding = "utf-8")
    header = "\t".join (["sample_name", "before_total_reads", "before_total_bases", "before_q20_bases", "before_q30_bases", "before_q20_rate", "before_q30_rate", "before_read1_mean_length", "before_read2_mean_length", "before_gc_content", "after_total_reads", "after_total_bases", "after_q20_bases", "after_q30_bases", "after_q20_rate", "after_q30_rate", "after_read1_mean_length", "after_read2_mean_length", "after_gc_content"])
    fw.write (header + "\n")
    for dir_path, dir_name, file_names in os.walk (f"{os.path.dirname (__file__)}/../cleandata/") : 
        for file_name in file_names : 
            if "json" in file_name : 
                sample_name = file_name.split (".")[0]
                file_path = os.path.join (dir_path, file_name)
                with open (file_path, "r", encoding = "utf-8") as fr : 
                    temp1 = json.load (fr)
                    temp2 = list (map (str, list (temp1["summary"]["before_filtering"].values ())))
                    before = "\t".join (temp2)
                    temp2 = list (map (str, list (temp1["summary"]["after_filtering"].values ())))
                    after = "\t".join (temp2)
                    mystr = sample_name + "\t" + before + "\t" + after + "\n"
                    fw.write (mystr)
                fr.close ()

    fw.close ()

if __name__ == "__main__" : 
    filter_stat ()
