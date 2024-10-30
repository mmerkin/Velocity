# Velocity
The code I used to process the velocity dataset


# Steps:

1) Run preprocessing script
2) Index reference file 
```bash
java -jar ~/apps/picard/build/libs/picard.jar CreateSequenceDictionary -R GCA_905404135.1.fasta -O GCA_905404135.1.dict
```
3) Run indel realignment script
4) Merge overlapping reads
5) Calculate coverage with this script
6) Downsample data with high coverage
7) Estimate errors
```bash
parallel -j 5 /pub64/mattm/apps/atlas/build/atlas estimateErrors --minDeltaLL 0.1 --fasta /pub64/mattm/velocity/sequence_files/Hesperia_comma/reference/GCA_905404135.1.fasta --bam {} ::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```
8) Create GLF 
```bash
parallel -j 8 /pub64/mattm/apps/atlas/build/atlas GLF --bam {} --RGInfo {.}_RGInfo.json ::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```
