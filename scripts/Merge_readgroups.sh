#! /bin/bash

all_files=
reseq_files=
output=
species_tag=

mkdir -p $output


# Extract the year and id, then copy and rename each file

for i in $all_files/*/*.bam; do 
reseq=$(echo $i | awk -F'-' '{print $4 "-" $5}' | awk -F'_' '{print $1}')
echo "Moving to: $reseq" 
cp $i $output/${species_tag}${reseq}.bam
done

# Merge files with the same year and id 

for i in $reseq_files/*/*.bam; do
reseq=$(echo $i | awk -F'-' '{print $4 "-" $5}' | awk -F'_' '{print $1}')
bamaddrg -b $all_files/*${reseq}*/*.bam -b $reseq_files/*${reseq}*/*.bam > $output/${species_tag}${reseq}.bam
done
