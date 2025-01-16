#! /bin/bash

datapath=


for i in $datapath/*veladapt.clean*.fastq.gz; do
sample=$(basename $i .fastq.gz)
echo "Moving to sample: $sample"
zcat $i | awk -F  ':' -v individual=$sample '{machine=$3 ; lane=$4; print > ""individual"_"machine"_"lane".fastq" ; for (i = 1; i <= 3; i++) {getline ; print > ""individual"_"machine"_"lane".fastq"}}'
done
