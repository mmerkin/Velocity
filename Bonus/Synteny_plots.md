I do not intend to use this just yet, but I was curious about the chromosome number increasing across the blue butterflies, so I plotted the synteny between 3 members of the genus *Polyommatus*. 
This file is to remind me of how I did so in case I ever come back to it.

First, I downloaded annotation files from DToL: data portal -> search for species -> Data tab -> Annotations gff3 file and the Proteins fasta file.

The gff3 file was then processed to create a four column bed file: chromosome, gene start pos, gene end pos, transcript name.
This requires conda installations found in my bedtools conda environment: bioconda::ucsc-gff3togenepred and bioconda::ucsc-genepredtobed. If this is throwing an error due to libssl1 not being found, 
openssl=1.0 should also be installed.

```bash
gff3ToGenePred  Polyommatus_icarus-GCA_937595015.1-2022_06-genes.gff3 icarus.pred

genePredToBed icarus.pred icarus_temp.bed

cut icarus_temp.bed -f 1-4 | sed 's/transcript://' > icarus.bed
```

The protein fasta file was also edited to make each heading the same as the transcript name from column 4 of the new bed file

```bash
sed -e 's/^.*transcript:/>/' -e  's/\.1.*//' < Polyommatus_icarus-GCA_937595015.1-2022_06-pep.fa > icarus.fa
```
The first sed substitute command replaces everything up to transcript: with a > symbol (to start the fasta heading), whilst the second gets rid of everything from .1 onwards

If an annotation is not available, one can be created by using [GALBA](https://github.com/Gaius-Augustus/GALBA) with protein sequences from a close relative. Note that I had to use my own laptop so I could have root permissions for singularity and it took 14 hours to run.

```bash
singularity exec galba.sif galba.pl --species=E_epiphron --genome=/home/matthewmerkin/Downloads/GCA_963932025.1_ilEreEpip2.1_genomic.fna --prot_seq=/home/matthewmerkin/Downloads/Erebia_ligea-GCA_917051295.2-2022_03-pep.fa --threads=12
```

Afterwards, the output gtf file can be modified to create a bed file for GENESPACE.

```bash
awk ' $3 == "transcript" {sub(/.*_chromosome:_/, "", $1); sub(/_Erebia_epiphron_genome_assembly.*/, "", $1); print $1 "\t" $4 "\t" $5 "\t" $9 }' < galba.gtf > E_epiphron_filtered.gtf
```

Finally, two new directories called "peptide" and "bed" are created and each file is added to the relevant directory.
```bash
/workingDirectory
└─ peptide
    └─ genome1.fa
    └─ genome2.fa
└─ bed
    └─ genome1.bed
    └─ genome2.bed
```

The actual plotting uses [GENESPACE](https://github.com/jtlovell/GENESPACE) in R, which can be installed from the instructions on the github page.

Here is the code to set up GENESPACE:

```R
library(GENESPACE)

wd <- "~/Documents/Velocity/Polyommatus_synteny"
path2mcscanx <- "~/Documents/GeneSpace_test/MCScanX"


gpar <- init_genespace(
  wd = wd,
  path2mcscanx = path2mcscanx)

out <- run_genespace(gpar, overwrite = T)

```

Here are some plots, followed by the code I used to create them:

![image](https://github.com/user-attachments/assets/d37f1351-af67-42c6-a347-a120347db354)


```R
roi <- data.frame(
  genome = c("coridon", "icarus"), 
  chr = c("Z", "Z"), 
  color = c("#FAAA1D", "#17B5C5"))
ripDat <- plot_riparian(
  gsParam = out, 
  highlightBed = roi,
  backgroundColor = NULL, # Remove uncoloured chromosomes
  refGenome = "icarus", 
  forceRecalcBlocks = FALSE)
```


![image](https://github.com/user-attachments/assets/be022700-942a-4fb9-b9f4-867ba333cd17)

```R
ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))
roi <- data.frame(
  genome = c("coridon", "icarus"), 
  chr = c("Z", "Z"), 
  color = c("#FAAA1D", "#17B5C5"))
ripDat <- plot_riparian(
  gsParam = out, 
  highlightBed = roi,
  backgroundColor = "lightgrey",
  refGenome = "icarus", 
  chrFill = "black",
  addThemes = ggthemes,
  forceRecalcBlocks = FALSE)
```

![image](https://github.com/user-attachments/assets/1f33b62b-a7a8-4075-ae05-c928686cd3ef)

```R
ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))
customPal <- colorRampPalette(
  c("#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C564B", "#E377C2"))
ripDat <- plot_riparian(
  gsParam = out, 
  palette = customPal,
  braidAlpha = .75,
  chrFill = "black",
  chrLabFontSize = 10,
  addThemes = ggthemes,
  refGenome = "ligea", 
  syntenyWeight = 1,
  labelTheseGenomes = c("NA"),
  forceRecalcBlocks = FALSE)
```
