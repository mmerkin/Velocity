#! /usr/bin/env Rscript 

index_file="/pub64/mattm/velocity/Aphantopus_hyperantus/reference/Ahyperantus_genome.fa.fai"
Z="LR761650.1"

faidx <- read.table(index_file)
chrom_length <- faidx$V2
names(chrom_length) <- faidx$V1

chrom_length <- chrom_length[names(chrom_length) != Z]

Mb <- chrom_length / 1000000
Total <- sum(Mb)
num <- 0

for (i in Mb){
  a <- 50/i
  b <- i/Total
  c <- a*b
  num <- num + c
}

print(round(num, digits = 1)/2)



#! /bin/bash

index_file="/pub64/mattm/velocity/Aphantopus_hyperantus/reference/Ahyperantus_genome.fa.fai"
Z="LR761650.1"

grep -v "$Z" $index_file | cut -f2 | awk '{ print $size / 1000000 }' >temp.txt
Total=$(awk '{ sum += $1 } END { print sum }' <temp.txt)
awk -v tot=$Total '{ print (50/$1)*($1/tot) }' <temp.txt | awk '{ sum += $1 } END { print sum/2 }' | awk '{printf("%.1f\n", $0)}'

rm temp.txt
