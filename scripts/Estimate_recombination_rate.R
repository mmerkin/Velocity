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

print(round(num, digits = 1))
