#! /bin/bash

# Frequently changed variables

REF=
datapath=
output=
threads=


# Exits the code if variables aren't set

if [[ -z $REF ]] || [[ -z $datapath ]] || [[ -z $output ]] || [[ -z $threads ]]; then
echo "At least one essential variable is missing. Make sure to define the variables before running the script" 
exit 1
fi

# Maps trimmed reads to reference

for file in "$datapath"/*.veladapt.clean_R1.fastq.gz; do 
filetag=$(basename "$file" ".veladapt.clean_R1.fastq.gz")
filepath="${datapath}/${filetag}"
if [[ $filetag =~ _L00[0-9] ]]; then  # Removes lane number from filetag if given
    filetag="${filetag/_L00[0-9]/}"
fi
echo $filetag
mkdir $output/$filetag  # Each file is added to a new directory
bwa-mem2 mem -t $threads $REF "${filepath}.veladapt.clean_R1.fastq.gz" "${filepath}.veladapt.clean_R2.fastq.gz" | samtools sort -o "$output/$filetag/${filetag}.sort.bam"
done
