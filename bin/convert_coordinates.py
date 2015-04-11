#########
# file: convert_coordinates.py
# description: Convert the x and y coordinates to latitude and longitude
########

import pandas as pd
import sys
from pyproj import Proj


def main(csv_in, csv_out):
  f = open(csv_in, 'r')
  df = pd.read_csv(csv_in, header=0, sep=',', usecols=[108-1, 109-1], nrows=1000)
  df = df.convert_objects(convert_numeric=True)
  df = df.astype('float')
  df = df.apply(lambda row: row*0.3048, axis=1)
  proj=Proj("+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000.0000000001 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
  results = df.apply(lambda row: proj(row['xcoord'], row['ycoord'], inverse=True), axis=1)
  results.to_csv(csv_out, sep=',', header=False, index=False)

def usage():
  sys.stderr.write("""
    Usage: python  [data.csv] [output.csv]
    """)

if __name__ == "__main__":
  if len(sys.argv) != 3:
    usage()
    sys.exit(1)
  main(sys.argv[1], sys.argv[2])


