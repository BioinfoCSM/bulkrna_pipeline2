#!/usr/bin/env python
# coding=utf-8

__author__ = "BioinfoCSM"
__version__ = "1.0"

import os
import argparse

parser = argparse.ArgumentParser (description = f"python {__file__}")
parser.parse_args ()

def alignment_stat () : 
    fw = open (f"{os.path.dirname (__file__)}/../alignment/alignment_stat.xls", "w")
    header = "\t".join (["sample_name", "alignment_ratio"]) + "\n"
    fw.write (header)
    for dir_path, dir_name, file_names in os.walk (f"{os.path.dirname (__file__)}/../alignment") : 
        for file_name in file_names : 
            if "log" in file_name : 
                sample_name = file_name.split (".")[0]
                file_path = os.path.join (dir_path, file_name)
                with open (file_path, "r") as fr : 
                    for line in fr : 
                        line = line.strip ()
                        if "Overall" in line : 
                            line = line.split (": ")[1]
                            mystr = "\t".join ([sample_name, line]) + "\n"
                            fw.write (mystr)
    fw.close ()
                
if __name__ == "__main__" : 
    alignment_stat ()
