#/bin/bash

if [[ $# -le 2 ]] ; then
    echo 'Please provide a file name and a destination name.'
    exit 0
fi

# Pick out the columns we want
echo "Reducing the number of columns";
cut --delimiter=, -f3-5 $1 | temp-reduced.csv

# Parse the CSV file we're going to want to use, doing relevant deletions and replacements
echo "Doing boolean replacement";
cat temp-reduced.csv | tr ',Y,' ',1,' | tr ',N,' ',0,' > $2

# Cleanup the intermediary files.
rm temp-reduced.csv
