# Velocity

A repository of all the scripts and code I used to complete the velocity PHD project. Explainations for each step are given below.

## Initial processing:

Before any analysis can begin, the reads must be mapped and processed. The rationale is explained below and instructions on how to perform each step are given here.
1) The reference genome is filtered to remove the W chromosome, mitochondria and unplaced scaffolds. Although all individuals are male, so they should not possess a W chromosome, this prevents misalignments and ensures that there are no haploid regions (mitochondria) that would interfere with heterozygosity stats. The genome is also indexed using various methods required for downstream analysis tools
2) Sequencing read files are trimmed to remove adaptor sequences and then mapped to the reference genome.
3) Read group information is added to specify the sequencing run of each individual. This is particularly important for species such as the chalk hill blue, where modern core samples were sequenced on two different flow cells, as there can be biases inherent to specific runs. Each alignment file is then filtered to only keep paired reads and those that are mapped in a proper pair, whilst excluding those where the read or its mate is unmapped, the read is in a secondary or supplementary alignment and the read has failed vendor quality checks. Afterwards, a mate score tag is added and any duplicates are removed (Figure 1), keeping the reads with the highest mate score.
4) Genome alignment tools often do a poor job at aligning indels (Figure 2), so GATK is used to perform a local realignment. 
5) Atlas is used to merge overlapping reads to prevent them from being counted twice, as explained by Merge_reads.md
6) Modern samples are downsampled, as explained here (work in progress)
7) The alignment files are recalibrated to account for inaccuracies in the base quality scores and post-mortem damage in the museum samples.
8) Genotype-likelihood (GLF) and variant-call format (vcf) files are created

![image](https://github.com/user-attachments/assets/7cb1bbc5-1084-4821-b991-ce9bcb755b81)

Figure 1. Slide from an illumina presentation explaining how duplicate reads can occur. Velocity data were sequenced on a patterned flow cell (HiSeq3000 or 4000), so have ExAmp (clustering) duplicates instead of optical duplicates. During the pipeline, any reads that are mapped to the same position and direction are removed (PCR and ExAmp), but sister duplicates remain. 

![image](https://github.com/user-attachments/assets/107402a5-44a2-47b2-bc40-39323db322c6)


Figure 2. GATK explanation of why indel realignment is necessary, which occurs due to bwa providing a larger penalty to gaps than mismatches ([link](https://qcb.ucla.edu/wp-content/uploads/sites/14/2016/03/GATKwr12-3-IndelRealignment.pdf)). This is not usually a problem as downstream variant callers will usually negate this effect, eg haploype-aware variant callers (Freebayes) will use the sequence information rather than the alignment. However, the atlas genotype likelihood files will be incorrect unless a local realignment is performed around indels.

Figure 3. Deamination. hDNA contains fragmented DNA with overhanging ends, where the unpaired cytosine residues are susceptible to a deamination reaction that will cause them to sponatenously convert to uracil. During library preparation, T4 DNA polymerase is added to create blunt ends for adaptor ligation, which has 5'-3' polymerase activity and 3'-5' exonuclease activity. This means that 3' overhangs are degraded and 5' overhangs are filled in, pairing any U bases with an A. Subsequent rounds of PCR amplification then replace the U with a T. This means that the 5' ends of sequencing reads will contain many C-to-T substitutions, whilst the 3' end of the complementary strand will have G-to-A substitutions, with the number of each decreasing exponentially from the fragment ends. Therefore, atlas corrects for these substituions using a model of exponential decay. 


To do:

-Add log file creation steps to each script
-Add catch to mapping script to remove lane number where relevant 
-Create missing github files based on below information and add links to README
-Create riparian plot for blue species with GENESPACE

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
