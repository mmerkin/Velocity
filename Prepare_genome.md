
# Index the reference genome

  1) Download genome from ncbi
  2) Create a list of all contigs in the genome
  ```bash
  grep ">" GCA_902806685.2_iAphHyp1.2_genomic.fna | sed 's/>//'
  ```
  3) Copy and paste contigs to be exlcuded (anything other than an autosome or Z) to a new text file
  4) Use seqkit (mem2 environment) to remove these contigs
  ```bash
  seqkit grep -v -n -f Ahyperantus_excluded_contigs.txt GCA_902806685.2_iAphHyp1.2_genomic.fna > Ahyperantus_genome.fa
  ```
  5) Index the fasta for samtools, bwa-mem2 and GATK
  ```bash
  samtools faidx Ahyperantus_genome.fa
  bwa-mem2 index Ahyperantus_genome.fa
  picard CreateSequenceDictionary -R Ahyperantus_genome.fa -O Ahyperantus_genome.dict
  ```
  6) Map reads to the file using the relevant script
