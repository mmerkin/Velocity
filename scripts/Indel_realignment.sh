#! /bin/bash

# Conda environment: GATK38

# Define frequently changed variables

REF=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/reference/GCA_902806685_noW.fa
datapath=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_test3
output=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_realign
fail_log=Ah_modc_realign_fails.txt


# Code


function realign_indels {
        name="$1"
        gatk3 \
        -T RealignerTargetCreator \
        -R $REF \
        -o "$output/$name/$name.intervals" \
        -I "$datapath/$name/$name.processed.bam"

        gatk3 \
        -T IndelRealigner \
        -R $REF \
        -targetIntervals "$output/$name/$name.intervals" \
        -I "$datapath/$name/$name.processed.bam" \
        -o "$output/$name/$name.realn.bam"
}

function print_error_file {
        echo $1 
}

for file in "$datapath"/*; do 
filetag=${file##*/}
mkdir -p $output/$filetag
realign_indels $filetag || print_error_file $filetag &>> $fail_log
done
