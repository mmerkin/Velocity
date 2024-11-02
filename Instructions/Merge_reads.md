# Merge overlapping reads

The final step of the bam filtering pipeline involves using ATLAS to merge overlapping read ends to prevent them from being counted twice.

First of all, a file specifying the merge parameters should be created containing the name of the read group, the fact that the reads are paired and the number of sequencing cycles.
Relevant parameters can be identified using the following command for one of the samples, noting that I added an alias for atlas within my .bashrc file:
'''bash
atlas BAMDiagnostics --splitMergeInput --bam 
...

'''bash
echo -e "readGroup\tseqType\tseqCycles" > AH_modc_RGS.txt
echo -e "E3modc\tpaired\t151" >> AH_modc_RGS.txt
'''
Merge overlapping reads
parallel -j 10 /pub64/mattm/apps/atlas/build/atlas mergeOverlappingReads --readGroupSettings AH_modc_RGS.txt \
--mergingMethod highestQuality --bam {} \
::: *.bam
5.5. Move files to a new directory and change their names

mv modc_realn/*realn_merged.bam* modc_merged
cd modc_merged
# Requires perl: cpan conda environment
rename s/realn_merged/final/ AH*
