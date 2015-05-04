#/bin/bash

if [[ $# -lt 2 ]] ; then
    echo 'Please provide a file name and a destination name.'
    exit 0
fi

#Remove quotes, parens and spaces. Replace unknown coordinates with 0
cat $1 | tr -d  '"(),' | sed s/1e+30/0/g > $2

#Reverse columns and put in temp file
awk '{print $2 "," $1}' $2 > temp.csv

#Add header
echo "lat,long" > $2

#Append content
cat temp.csv >> $2

#Remove temp file
rm temp.csv
