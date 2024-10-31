#! /bin/bash

REF=/pub64/mattm/velocity/Aphantopus_hyperantus/reference/Ahyperantus_genome.fa
datapath=/pub61/florat/velocity/aphantopus_hyperantus/modern_data/00_raw_reads_modc/Samples
output=/pub64/mattm/velocity/Aphantopus_hyperantus/modc_mapping
threads=32

for file in "$datapath"/*.veladapt.clean_R1.fastq.gz; do 
filetag=$(basename "$file" ".veladapt.clean_R1.fastq.gz")
filepath="${datapath}/${filetag}"
bwa-mem2 mem -t $threads $REF "${filepath}.veladapt.clean_R1.fastq.gz" "${filepath}.veladapt.clean_R2.fastq.gz" | samtools sort -o "$output/${filetag}.sort.bam"
done
