#! /bin/bash

datapath=
output=
readGroup=
seqCycles=
ATLAS=


## Code

mkdir -p $output

echo -e "readGroup\tseqType\tseqCycles\n${readGroup}\tpaired\t${seqCycles}" > "${readGroup}_RGS.txt"

for file in "$datapath"/*realn.bam; do 
filename=${file##*/}
filetag=$(basename "$filename" ".bam")
reduced_filetag=$(basename "$filename" ".realn.bam")

$ATLAS trimSoftClips --bam $file

$ATLAS mergeOverlappingReads \
--readGroupSettings "${readGroup}_RGS.txt" \
--removeSoftClippedBases \
--bam "${datapath}/${filetag}_softClippedBasesRemoved.bam"

cp "${datapath}/${filetag}_softClippedBasesRemoved_merged.bam" "$output/${reduced_filetag}_final.bam"
cp "${datapath}/${filetag}_softClippedBasesRemoved_merged.bam.bai" "$output/${reduced_filetag}_final.bam.bai"

done
