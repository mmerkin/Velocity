# Velocity
The code I used to process the velocity dataset


## Steps:

1) Run preprocessing script
2) Index reference file 
```bash
java -jar ~/apps/picard/build/libs/picard.jar CreateSequenceDictionary -R GCA_905404135.1.fasta -O GCA_905404135.1.dict
```
3) Run indel realignment script
4) Create info file for each read group
```bash
echo -e "E3modc\tpaired\t151" > AH_modc_RGS.txt
```
5) Merge overlapping reads
```bash
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas mergeOverlappingReads --bam {} --readGroupSettings AH_modc_RGS.txt ::: /pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_realign/*.bam
```
6) Calculate coverage with this script
7) Downsample modern data based on coverage
8) Estimate errors
8.1) Modern samples
```bash
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas estimateErrors --minDeltaLL 0.1 --Npsi 0 \
--fasta /pub64/mattm/velocity/sequence_files/Hesperia_comma/reference/GCA_905404135.1.fasta --bam {} \
::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```
8.2) Museum samples
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
