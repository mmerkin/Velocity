#! /bin/bash

datapath=
output=
readGroup=
seqCycles=
$ATLAS=

## Code



echo -e "readGroup\tseqType\tseqCycles\n$readGroup\tpaired\t$seqCycles" > "${readGroup}_RGS.txt"

for file in "$datapath"/*/*realn.bam; do 
filename=${file##*/}
filetag=$(basename "$filename" ".bam")
reduced_filetag=$(basename "$filename" ".realn.bam")
mkdir -p $output/$reduced_filetag

$ATLAS trimSoftClips --bam $file

$ATLAS mergeOverlappingReads \
--readGroupSettings "${readGroup}_RGS.txt" \
--removeSoftClippedBases \
--bam "$datapath/$reduced_filetag/${filetag}_softClippedBasesRemoved.bam"

cp "${datapath}/$reduced_filetag/${filetag}_softClippedBasesRemoved_merged.bam" "$output/$reduced_filetag/${reduced_filetag}_final.bam"
cp "${datapath}/$reduced_filetag/${filetag}_softClippedBasesRemoved_merged.bam.bai" "$output/$reduced_filetag/${reduced_filetag}_final.bam.bai"

done
