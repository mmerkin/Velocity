#! /bin/bash

# Conda environment: depth

datapath=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_merged
filetype=realn_merged.bam
output=Ah_modc_depths.tsv


first=true
for file in "$datapath"/*"$filetype"; do 
filename=${file##*/}
filetag=$(basename "$filename" ."$filetype")

if $first; then
        echo -e "Sample_id\tMean_depth"
        first=false
fi

mosdepth -n -x temp_depth $file
depth=$(awk '$1 == "total" { print $4 }' < temp_depth.mosdepth.summary.txt)
echo -e "${filetag}\t${depth}"
done > $output

#rm temp_depth.mosdepth.global.dist.txt  temp_depth.mosdepth.summary.txt
