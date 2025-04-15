#!/bin/bash

top_n=10
G123_file="sorted_C2_G123.txt"
gff_file="genes.gff3"


head -n $top_n $G123_file | while read line; do
  read chrom_alias window_start window_end _ _ _ _ value <<< $(echo $line)
  
  chrom=$(grep -P "\bAlias=$chrom_alias\b" $gff_file | awk -F'\t' '{match($9, /ID=region:([^;]+)/, chr); print chr[1]}')  # Convert id into number by extracting match after "region"
  if [ -z "$chrom" ]; then
	chrom=$chrom_alias
  fi
  echo "Checking for genes in chromosome $chrom, window [$window_start, $window_end]"

  result=$(awk -v chrom="$chrom" -v start="$window_start" -v end="$window_end" '
    $1 == chrom && $3 == "gene" && $4 <= end && $5 >= start {print $0}
  ' $gff_file)

  if [ -z "$result" ]; then
    echo "No genes found in window [$window_start, $window_end] on chromosome $chrom"
  else
    echo "$result" | while read gene; do # Print out each gene name (there may be multiple)
      echo "Gene found: $gene"
    done
  fi
done
