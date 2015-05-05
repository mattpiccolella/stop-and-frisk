#!/bin/sh

# Part 1: Pruning the Data
echo "Pruning the data..."
unzip data/2012-data.csv.zip -d data/
bin/parse_csv.sh data/2012.csv data/2012-data-pruned.csv

# Part 1 (Optional): Generating Coordinates
# In this part, we generate latitudes and longitudes for our Stop and Frisk data. We do this using
# a Python script which relies on a library called Pandas. This is both a non-default library and
# the script takes a long time to run. We ran it once, with Pandas installed, to generate the data
# we would later need. Uncomment the following lines if you would like to generate these.
# echo "Generating coordinates for stops..."
# python bin/convert_coordinates.py data/2012.csv v11n/data/coordinates.csv
# bin/reformat.sh v11n/data/coordinates.csv v11n/data/coordinates-fixed.csv
# grep -v '0,0' v11n/data/coordinates-fixed.csv > v11n/data/coordinates-pruned.csv
# rm v11n/data/coordinates-fixed.csv
# rm v11n/data/coordinates.csv

# Part 2: Preliminary Data Analysis
echo "Performing initial data analysis and visualization..." 
Rscript analysis/preliminary-stats.R

# Part 3: Prediction Using Navie Bayes and Logistic Regression
echo "Make folder for output files"
mkdir analysis/output
echo "Performing classification..."
Rscript analysis/prediction.R