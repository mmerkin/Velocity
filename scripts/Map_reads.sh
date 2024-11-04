#! /bin/bash

REF=
datapath=
output=
threads=

for file in "$datapath"/*.veladapt.clean_R1.fastq.gz; do 
filetag=$(basename "$file" ".veladapt.clean_R1.fastq.gz")
filepath="${datapath}/${filetag}"
bwa-mem2 mem -t $threads $REF "${filepath}.veladapt.clean_R1.fastq.gz" "${filepath}.veladapt.clean_R2.fastq.gz" | samtools sort -o "$output/${filetag}.sort.bam"
done
