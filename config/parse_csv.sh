#/bin/bash

if [[ $# -lt 2 ]] ; then
    echo 'Please provide a file name and a destination name.'
    exit 0
fi

# Pick out the columns we want
echo "Reducing the number of columns";
cut -d ',' -f1-2,4-5,10,15-18,21,23-25,27-41,43-81,85-94,99-103,105,108,116 $1 > temp-reduced.csv

# Parse the CSV file we're going to want to use, doing relevant deletions and replacements
echo "Doing boolean replacement";
cat temp-reduced.csv | tr ',Y,' ',1,' | tr ',N,' ',0,' > $2

# Cleanup the intermediary files.
rm temp-reduced.csv
