######################
# get_columns.py
#
# Script to get the desired columns from the csv data file
# python get_columns [req.txt]
# 
# reqs.txt example:
# file_in.txt
# file_out.txt
# 1, 2, 89, 40 
######################


import pandas as pd
import sys

def main(requirements_file):
  f = open(requirements_file, 'r')
  reqs = []
  for line in f:
    reqs.append(line)
  if (len(reqs) != 3):
    usage()
  else:
    file_in = reqs[0].strip()
    file_out = reqs[1].strip()
    cols = reqs[2].strip().split(',')
    cols = map((lambda x: int(x)-1), cols)
    read_and_write(file_in, file_out, cols)

def read_and_write(file_in, file_out, cols):
  df = pd.read_csv(file_in, header=0, usecols=cols)
  df.to_csv(file_out, sep=',', header=True, index=False)

def usage():
  sys.stderr.write("""
    Usage: python get_colums [requirements_file]

    requirements_file example:
    file_in.csv
    file_out.csv
    1, 2, 15\n""")


if __name__ == "__main__":
  if len(sys.argv) != 2:
    usage()
    sys.exit(1)
  print(sys.argv[1])
  main(sys.argv[1])
  