#!/bin/bash

echo Creating word frequency tallies...
sed -e 's/ /\n/g' -e 's/[^a-zA-Z\n]//g' corpus.txt | \
  tr [:upper:] [:lower:] | \
  sort | \
  uniq -c | \
  sort -rn > frequency.txt

echo Creating lexicon...
grep -Fwf dictionary.txt frequency.txt | awk '{print $2 "," $1}' > lexicon.csv

echo Creating lexicon without single-occurrence 3-letter words...
grep -v "^[a-z][a-z][a-z],1" lexicon.csv > lexicon-3.csv
