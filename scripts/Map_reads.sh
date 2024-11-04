#! /bin/bash

# Frequently changed variables

REF=
datapath=
output=
threads=


# Exits the code if variables aren't set

if [[ -z $REF ]]; then
echo "No reference detected. Make sure to define the variables before running the script" 
exit 1
fi

# Maps trimmed reads to reference

for file in "$datapath"/*.veladapt.clean_R1.fastq.gz; do 
filetag=$(basename "$file" ".veladapt.clean_R1.fastq.gz")
filepath="${datapath}/${filetag}"
bwa-mem2 mem -t $threads $REF "${filepath}.veladapt.clean_R1.fastq.gz" "${filepath}.veladapt.clean_R2.fastq.gz" | samtools sort -o "$output/${filetag}.sort.bam"
done
