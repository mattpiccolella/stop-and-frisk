#!/bin/sh

# Part 1: Pruning the Data
unzip data/2012-data.csv.zip -d data/
bin/parse_csv.sh data/2012.csv data/2012-data-pruned.csv

# Part 1 (Optional): Generating Coordinates
# In this part, we generate latitudes and longitudes for our Stop and Frisk data. We do this using
# a Python script which relies on a library called Pandas. This is both a non-default library and
# the script takes a long time to run. We ran it once, with Pandas installed, to generate the data
# we would later need. Uncomment the next line if you would like to generate these.
# python convert_coordinates.py

# Part 2: Preliminary Data Analysis
echo "Performing initial data analysis and visualization..." 
Rscript analysis/preliminary-stats.R