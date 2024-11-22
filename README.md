# Velocity

A repository of all the scripts and code I am using to complete the velocity PHD project starting in October 2024. The rationale for performing each step is given below, along with links to instructions on how to carry them out.

Certain commands require particular tools to run; most of these can be downloaded from the revelant [conda environment yaml file](Conda_environments) using the following command:
```bash
 conda create --name $ENVIRONMENT_NAME --file $PATH/TO/FILE.yaml
```

## Initial processing:
Before any analysis can begin, the reads must be mapped and processed.

[1.1. Genome preparation.](Instructions/1.1.Prepare_genome.md) The reference genome is downloaded, filtered to remove the W chromosome (to prevent incorrect alignments from all male samples) and indexed.

[1.2. Read mapping.](Instructions/1.2.Map_reads.md) The reads are mapped to the reference genome

[1.3. Alignment processing.]() Read group information is added to specify the sequencing run of each individual. This is particularly important for species such as the chalk hill blue, where modern core samples were sequenced on two different flow cells, as there can be biases inherent to specific runs. Each alignment file is then filtered to only keep paired reads and those that are mapped in a proper pair, whilst excluding those where the read or its mate is unmapped, the read is in a secondary or supplementary alignment, the read has failed the quality checks of the sequencing machine or the read has a mapping quality score below 20 (99% chance of being accurate). Secondary alignments are the result of a read mapping to multiple places (only the primary/most confident is kept), whereas supplementary alignments occur when the read has been split in two (eg the read spans a large deletion so will be mapped to either side of it); both of these are removed as they can introduce errors and we are only interested in snps. Afterwards, a mate score tag is added and any duplicates are removed by looking for multiple reads with same position and direction (Figure 1), keeping the reads with the highest mate score. It is important to remove duplicates as they can give the impression that an allele is at a higher frequency than it actually is. Finally, the mitochondria and unplaced scaffolds are removed as we are only interested in the autosomes + Z. 

![image](https://github.com/user-attachments/assets/7cb1bbc5-1084-4821-b991-ce9bcb755b81)

Figure 1. Illumina's explanation of how duplicates occur ([link](https://core-genomics.blogspot.com/2016/05/increased-read-duplication-on-patterned.html)). Top: Illumina sequencing involves a bridge amplification step, which generates clusters of reads. TL: In unpatterned flow cells, oddly-shaped clusters could be mistaken for two separate clusters, producing optical duplicates. TR: Patterned flow cells use a method called exclusion amplification, where the flow cell contains wells and the first read to enter a well is amplified so quickly that other reads are not given a chance to bind. However, bridge amplification involves the original unbound strand leaving after being copied, so it could enter an adjacent well to form clustering/Examp duplicates.Velocity data were sequenced on a patterned flow cell (HiSeq3000 or 4000), so have ExAmp (clustering) duplicates instead of optical duplicates. BL: The library prep stage uses PCR to amplify the original DNA fragments (with adaptors), so multiple copies can enter the flow cell and form separate clusters. BR: dsDNA is added to the flow cell, which is then denatured to form two strands that may both be sequenced as sister duplicates; these are not filtered out, but they are very rare as they do not have the correct adaptor sequence to bind to the sequencing probe. 

[1.4. Realignment around indels.](Instructions/1.4.Indel_realignment.md) Genome alignment tools often do a poor job at aligning indels (Figure 2), so GATK is used to perform a local realignment. 

![image](https://github.com/user-attachments/assets/107402a5-44a2-47b2-bc40-39323db322c6)

Figure 2. GATK explanation of why indel realignment is necessary, which occurs due to bwa providing a larger penalty to gaps than mismatches ([link](https://qcb.ucla.edu/wp-content/uploads/sites/14/2016/03/GATKwr12-3-IndelRealignment.pdf)). This is not usually a problem as downstream variant callers will usually negate this effect, eg haploype-aware variant callers (Freebayes) will use the sequence information rather than the alignment. However, the atlas genotype likelihood files will be incorrect unless a local realignment is performed around indels.

[1.5. Atlas further processing.](Instructions/1.5.Atlas_processing.md) The aligned reads must go through an additional round of processing using Atlas. This removes soft clipped bases, where part of the read does not align to the reference; these can be useful for detecting indels, but here they just increase the chance of a misalignment. Additionally, ancient DNA can be highly fragmented, so many of the libraries will be shorter than 152 bp. As such, the sequencing of 76 bases from either end will result in an overlap between the two read pairs. Therefore, Atlas is also used to merge any overlapping reads into a single read to prevent the depth of these regions from being artifically inflated in a similar manner to duplicate reads.

[1.6. Error recalibration.](Instructions/1.6.Error_recalibration.md) Sequencing machines produce base quality scores as a probability of each base call being incorrect (eg a score of 40 means the base has a 1 in 10000 chance of being incorrect ie a 99.99% chance of being correct). However, these are often really inaccurate, so must be recalibrated by Atlas before genotype likelihood files can be generated, which rely heavily on quality scores. Additionally, the same command corrects for post-mortem damage (Figure 3) in the museum samples. This is the rate-limiting step as it can take up to 17 hours to run for a single sample, which still amounts to days if multiple samples are run at the same time (all the other steps only take a few hours at most)

![image](https://github.com/user-attachments/assets/912da626-3e0a-4159-838e-581dfa76e5c3)

Figure 3. An overview of how post-mortem deamination can affect base calls. A) aDNA contains fragmented DNA with overhanging ends, where the unpaired cytosine residues are susceptible to a deamination reaction that will cause them to sponatenously convert to uracil. B) During library preparation, T4 DNA polymerase is added to create blunt ends for adaptor ligation, which has 5'-3' polymerase activity and 3'-5' exonuclease activity. This means that 3' overhangs are degraded and 5' overhangs are filled in, pairing any U bases with an A. Subsequent rounds of PCR amplification then replace the U with a T. C) As a result, the 5' ends of sequencing reads will contain many C-to-T substitutions, whilst the 3' end of the complementary strand will have G-to-A substitutions, with the number of each decreasing exponentially from the fragment ends. Therefore, atlas corrects for these substituions using a model of exponential decay. A and C were taken from [here](https://pmc.ncbi.nlm.nih.gov/articles/PMC3685887/) and [here](https://www.pnas.org/doi/10.1073/pnas.0704665104), whilst B was adapted from [here](https://www.cytivalifesciences.com/en/us/news-center/enzymes-in-ngs-library-prep-10001).

1.6. Downsampling instructions will go here once completed. Samples at super low coverage have an artifically inflated diveristy estimate due to sequencing errors and the inability to call both alleles when the depth is less than 2. As such, the modern samples at higher coverage are downsampled to bring them in line with the museum estimates to enable greater comparison. This will likely involve 2 steps: a depth calculation based on mosdepth and then downsampling with Atlas.

[1.7. Final input file creation.] Finally, the alignments (bam files) produced in step #4 and the recalibration parameters from step #5 (json file) can be used to generate the final genotype likelihood files which can be used directly to infer many different statistics. Some of these many also require a vcf or sfs file, which are also generated in this step. The vcf is created by assuming that each site is a biallelic SNP and calling the major and minor alleles for that site across all individuals.


## Population level analyses

[2.1. Effective population size.](Instructions/2.1.GONE.md) *N<sub>e</sub>*, is a measure of the number of individuals in a whole population that actually contribute to the gene pool, which is smaller than the census population size, *N<sub>c</sub>*. *N<sub>e</sub>* can be estimated genetically based on linkage disequilibrium, with WGS allowing for inferrance of the *N<sub>e</sub>* from previous generations as well based on a high number of linked markers. 



```bash
#! /bin/bash

index_file="/pub64/mattm/velocity/Aphantopus_hyperantus/reference/Ahyperantus_genome.fa.fai"
Z="LR761650.1"

awk -v Z="$Z" '{
    if ($1 != Z) {
        size = $2 / 1000000
        sizes[NR] = size
        total += size
        iteration++
    }
}
END {
    for (i = 1; i <= iteration; i++) {
        weighted_r_sum += (50 / sizes[i]) * (sizes[i] / total)
    }
    printf("%.1f\n", weighted_r_sum / 2)
}' "$index_file"

# Alternatively:

awk -v Z="LR761650.1" '{
    if ($1 != Z ) {
        size = $2 / 1000000
        total += size
        iteration++
    }
}
END {
    weighted_r_sum = (50 / total) * iteration
    printf("%.1f\n", weighted_r_sum / 2)
}' Ahyperantus_genome.fa.fai
```




# Notes

Ignore the below information, I will relocate it somewhere else later

To do:

-Add log file creation steps to each script

-test soft clip removal in latest version of atlas

-View PMD patterns with atlas viewer R tool

Here are two useful commands that I keep forgetting how to perform
```bash
# Requires perl: cpan conda environment
rename s/realn_merged/final/ AH*
# Check disk usage
du * -sh
```

This is how to perform the GLF creation using parallel
```bash
parallel -j 8 /pub64/mattm/apps/atlas/build/atlas GLF --bam {} --RGInfo {.}_RGInfo.json ::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```


