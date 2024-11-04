# Velocity

A repository of all the scripts and code I am using to complete the velocity PHD project starting in October 2024. The rationale for performing each step is given below, along with links to instructions on how to carry them out.

Certain commands require particular tools to run; most of these can be downloaded from the revelant [conda environment yaml file](Conda_environments) using the following command:
```bash
 conda create --name $ENVIRONMENT_NAME --file $PATH/TO/FILE.yaml
```

## Initial processing:
Before any analysis can begin, the reads must be mapped and processed.

[1.1. Genome preparation.](Instructions/1.1.Prepare_genome.md) The reference genome is filtered to remove the W chromosome, mitochondria and unplaced scaffolds. Although all individuals are male, so they should not possess a W chromosome, this prevents misalignments and ensures that there are no haploid regions (mitochondria) that would interfere with heterozygosity stats. The genome is also indexed using various methods required for downstream analysis tools

[1.2. Read mapping.](Instructions/1.2.Map_reads.md) Sequencing read files are trimmed to remove adaptor sequences and then mapped to the reference genome.

[1.3. Alignment processing. ](Instructions/1.3.Process_bams.md) Read group information is added to specify the sequencing run of each individual. This is particularly important for species such as the chalk hill blue, where modern core samples were sequenced on two different flow cells, as there can be biases inherent to specific runs. Each alignment file is then filtered to only keep paired reads and those that are mapped in a proper pair, whilst excluding those where the read or its mate is unmapped, the read is in a secondary or supplementary alignment, the read has failed the quality checks of the sequencing machine or the read has a mapping quality score below 20 (99% chance of being accurate). Secondary alignments are the result of a read mapping to multiple places (only the primary/most confident is kept), whereas supplementary alignments occur when the read has been split in two (eg the read spans a large deletion so will be mapped to either side of it); both of these are removed as they can introduce errors and we are only interested in snps. Afterwards, a mate score tag is added and any duplicates are removed by looking for multiple reads with same position and direction (Figure 1), keeping the reads with the highest mate score. It is important to remove duplicates as they can give the impression that an allele is at a higher frequency than it actually is.

![image](https://github.com/user-attachments/assets/7cb1bbc5-1084-4821-b991-ce9bcb755b81)

Figure 1. Illumina's explanation of how duplicates occur ([link](https://core-genomics.blogspot.com/2016/05/increased-read-duplication-on-patterned.html)). Top: Illumina sequencing involves a bridge amplification step, which generates clusters of reads. TL: In unpatterned flow cells, oddly-shaped clusters could be mistaken for two separate clusters, producing optical duplicates. TR: Patterned flow cells use a method called exclusion amplification, where the flow cell contains wells and the first read to enter a well is amplified so quickly that other reads are not given a chance to bind. However, bridge amplification involves the original unbound strand leaving after being copied, so it could enter an adjacent well to form clustering/Examp duplicates.Velocity data were sequenced on a patterned flow cell (HiSeq3000 or 4000), so have ExAmp (clustering) duplicates instead of optical duplicates. BL: The library prep stage uses PCR to amplify the original DNA fragments (with adaptors), so multiple copies can enter the flow cell and form separate clusters. BR: dsDNA is added to the flow cell, which is then denatured to form two strands that may both be sequenced as sister duplicates; these are not filtered out, but they are very rare as they do not have the correct adaptor sequence to bind to the sequencing probe. 

[1.4. Realignment around indels. ](Instructions/1.4.Indel_realignment.md) Genome alignment tools often do a poor job at aligning indels (Figure 2), so GATK is used to perform a local realignment. 

![image](https://github.com/user-attachments/assets/107402a5-44a2-47b2-bc40-39323db322c6)

Figure 2. GATK explanation of why indel realignment is necessary, which occurs due to bwa providing a larger penalty to gaps than mismatches ([link](https://qcb.ucla.edu/wp-content/uploads/sites/14/2016/03/GATKwr12-3-IndelRealignment.pdf)). This is not usually a problem as downstream variant callers will usually negate this effect, eg haploype-aware variant callers (Freebayes) will use the sequence information rather than the alignment. However, the atlas genotype likelihood files will be incorrect unless a local realignment is performed around indels.

5) Atlas is used to further process the reads by removing soft clipped bases, where part of the read does not align to the reference; these can be useful for detecting indels, but we only want to look at SNPS, so soft-clipping will just increase the chance of a misalignment. Additionally, overlapping read ends are merged to prevent them from being counted twice (in a similar manner to duplicate reads).
6) Sequencing machines produce base quality scores as a probability of each base call being incorrect (eg a score of 40 means the base has a 1 in 10000 chance of being incorrect ie a 99.99% chance of being correct). However, these are often really inaccurate, so must be recalibrated by atlas before genotype likelihood files can be generated, which rely heavily on quality scores. Additionally, the same command corrects for post-mortem damage (Figure 3) in the museum samples. This is the rate-limiting step as it can take up to 17 hours to run for a single sample, which still amounts to days if multiple samples are run at the same time (all the other steps only take a few hours at most)
7) Super low coverage results in overestimations for genome diversity, so the modern samples will be downsampled to match the lower coverage of the museum samples. This step is still a work in progress.
8) Finally, the alignments (bam files) produced in step #6 and the recalibration parameters from step #7 (json file) can be used to generate the final genotype likelihood files which can either be analysed directly or used to call variants to create a vcf file for downstream analysis





![image](https://github.com/user-attachments/assets/912da626-3e0a-4159-838e-581dfa76e5c3)

Figure 3. An overview of how post-mortem deamination can affect base calls. A) aDNA contains fragmented DNA with overhanging ends, where the unpaired cytosine residues are susceptible to a deamination reaction that will cause them to sponatenously convert to uracil. B) During library preparation, T4 DNA polymerase is added to create blunt ends for adaptor ligation, which has 5'-3' polymerase activity and 3'-5' exonuclease activity. This means that 3' overhangs are degraded and 5' overhangs are filled in, pairing any U bases with an A. Subsequent rounds of PCR amplification then replace the U with a T. C) As a result, the 5' ends of sequencing reads will contain many C-to-T substitutions, whilst the 3' end of the complementary strand will have G-to-A substitutions, with the number of each decreasing exponentially from the fragment ends. Therefore, atlas corrects for these substituions using a model of exponential decay. A and C were taken from [here](https://pmc.ncbi.nlm.nih.gov/articles/PMC3685887/) and [here](https://www.pnas.org/doi/10.1073/pnas.0704665104), whilst B was adapted from [here](https://www.cytivalifesciences.com/en/us/news-center/enzymes-in-ngs-library-prep-10001).


To do:

-Add log file creation steps to each script
-Add catch to mapping script to remove lane number where relevant 
-Create missing github files based on below information and add links to README
-Create riparian plot for blue species with GENESPACE

```bash
# Requires perl: cpan conda environment
rename s/realn_merged/final/ AH*
# Check disk usage
du * -sh
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
