# Velocity
The code I used to process the velocity dataset


# Steps:

1) Filter museum -> develop filtering pipeline -> Atlas
```bash
parallel -j 5 /pub64/mattm/apps/atlas/build/atlas estimateErrors --minDeltaLL 0.1 --fasta /pub64/mattm/velocity/sequence_files/Hesperia_comma/reference/GCA_905404135.1.fasta --bam {} ::: /pub64/mattm/velocity/sequence_files/Hesperia_comma/marked_duplicates/*.bam
```
Workflow:

-> mark duplicates, merge overlapping reads, calculate coverage, estimate errors, glf


3) Filter modern -> develop filtering pipeline

-> same as above but with downsampling instead of estimate errors by calculating average coverage for each individual

4) Calculate average coverage for all individuals
5) Downsample modern samples to be in line with museum using atlas
6) Use modern samples to make predictions about museum samples eg use LD to estimate Ne etc and see how it compares to the data
