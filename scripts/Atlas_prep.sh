#! /bin/bash

datapath=/pub64/mattm/velocity/Aphantopus_hyperantus/modc_realign
output=/pub64/mattm/velocity/Aphantopus_hyperantus/modc_final
readGroup=E3modc
seqCycles=151

ATLAS=/pub64/mattm/apps/atlas/build/atlas


mkdir -p $output

echo -e "readGroup\tseqType\tseqCycles\n${readGroup}\tpaired\t${seqCycles}" > "${readGroup}_RGS.txt"

for file in "$datapath"/*realn.bam; do 
filename=${file##*/}
filetag=$(basename "$filename" ".bam")

$ATLAS trimSoftClips --bam $file

$ATLAS mergeOverlappingReads \
--readGroupSettings "${readGroup}_RGS.txt" \
--mergingMethod highestQuality \
--bam "${datapath}/${filetag}_softClippedBasesRemoved.bam"

cp "${datapath}/${filetag}_merged.bam" "$output/${filetag}_final.bam"

done
