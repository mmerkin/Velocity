#! /bin/bash

dir1=
dir2=
dir3=
dir4=
dir5=
dir6=
output=
species_tag=

mkdir -p $output

# Merge files with the same year and id 

for i in $dir1/*/*.bam; do
reseq=$(echo $i | awk -F'-' '{print $6 "-" $7}')
bamaddrg -b $dir1/*${reseq}*/*.bam \
-b $dir2/*${reseq}*/*.bam \
-b $dir3/*${reseq}*/*.bam \
-b $dir4/*${reseq}*/*.bam \
-b $dir5/*${reseq}*/*.bam \
-b $dir6/*${reseq}*/*.bam \
> $output/${species_tag}${reseq}.bam
done
