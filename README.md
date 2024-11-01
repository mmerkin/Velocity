# Velocity
The code I used to process the velocity dataset


## Steps:

1) Process the reference genome, as exolained here
2) Map illumina reads to the reference using this script
3) Realign indels using this script
4) Create info file for each read group
```bash
echo -e "E3modc\tpaired\t151" > AH_modc_RGS.txt
```
5) Merge overlapping reads
```bash
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas mergeOverlappingReads --bam {} --readGroupSettings AH_modc_RGS.txt ::: /pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_realign/*.bam
```
5.5. Move files to a new directory and change their names
```bash
mv modc_realn/*realn_merged.bam* modc_merged
cd modc_merged
# Requires perl: cpan conda environment
rename s/realn_merged/final/ AH*
```

6) Calculate coverage with this script
7) Downsample modern data based on coverage
8) Estimate errors

8.1. Modern samples
```bash
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas estimateErrors --minDeltaLL 0.1 --NPsi 0 \
--fasta /pub64/mattm/velocity/sequence_files/Hesperia_comma/reference/GCA_905404135.1.fasta --bam {} \
::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```

  8.2. Museum samples
```bash
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas estimateErrors --minDeltaLL 0.1  \
--fasta /pub64/mattm/velocity/sequence_files/Hesperia_comma/reference/GCA_905404135.1.fasta --bam {} \
::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam

```
9) Create GLF 
```bash
parallel -j 8 /pub64/mattm/apps/atlas/build/atlas GLF --bam {} --RGInfo {.}_RGInfo.json ::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```



## Issues:

Indel realignment fails on Z chromosome of *Hesperia comma*, but *Aphantopus hyperantus* works fine

Solution: *H. comma* realignment works after remapping one individual. I should start over and remap every individual following the removal of relevant contigs (W chromosome, mtDNA, unplaced contigs)
```bash
#exclude_contigs.txt created using grep ">" Hc_genome.fa and copying relevnat contigs to a text file (without the '>')
seqkit grep -v -n -f exclude_contigs.fa Hc_genome.fa > Hc_genome_noW.fa

bwa-mem2 mem -t 32 Hc_genome_noW.fa HC-19-2016-21_L007.veladapt.clean_R1.fastq.gz HC-19-2016-21_L007.veladapt.clean_R2.fastq.gz > "HC-19-2016-21_L007.raw.bam"
```
