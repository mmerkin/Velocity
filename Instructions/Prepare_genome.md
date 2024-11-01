# Prepare the reference genome

DToL have currently released 18/20 reference genomes, 17 of which have been annotated. Before mapping can begin, these must be downloaded, processed to remove unwanted contigs and indexed.

Genome files can be downloaded from the ncbi genome page using curl:
```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/806/685/GCF_902806685.2_iAphHyp1.2/GCF_902806685.2_iAphHyp1.2_genomic.fna.gz
```
A list of all contigs can then be created using grep:
```bash
grep ">" GCA_902806685.2_iAphHyp1.2_genomic.fna | sed 's/>//'
```

Copy and paste a list of contigs to be excluded (anything other than an autosome or Z) to a new text file and use seqkit (mem2 environment) to remove these contigs
```bash
seqkit grep -v -n -f Ahyperantus_excluded_contigs.txt GCA_902806685.2_iAphHyp1.2_genomic.fna > Ahyperantus_genome.fa
```
Finally, index the fasta for samtools, bwa-mem2 and GATK
```bash
samtools faidx Ahyperantus_genome.fa
bwa-mem2 index Ahyperantus_genome.fa
picard CreateSequenceDictionary -R Ahyperantus_genome.fa -O Ahyperantus_genome.dict
```