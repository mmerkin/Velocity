#!/bin/bash

datapath=/path/to/bams
output=output_depths.tsv
chr_list=/path/to/chromosome/list.txt


all_bases=true 
first=true

for i in ${datapath}/*.bam; do
    filetag=$(basename "$i" .bam)

    if $first; then
        echo -e "Sample_id\tWeighted_Mean_Depth" > "$output"
        first=false
    fi

    mosdepth -n -x temp_depth "$i"

    if $all_bases; then
        depth=$(awk '
        NR==FNR { chrom[$1]; next }
        $1 in chrom {
            total += $2
            weighted += $2 * $4
        }
        END {
            print (total > 0) ? weighted / total : 0
        }' "$chr_list" temp_depth.mosdepth.summary.txt)
    else
        # Use 'bases' (column 3)
        depth=$(awk '
        NR==FNR { chrom[$1]; next }
        $1 in chrom {
            total += $3
            weighted += $3 * $4
        }
        END {
            print (total > 0) ? weighted / total : 0
        }' "$chr_list" temp_depth.mosdepth.summary.txt)
    fi

    echo -e "${filetag}\t${depth}" >> "$output"
    done

rm temp_depth*
