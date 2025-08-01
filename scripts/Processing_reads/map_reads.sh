# Frequently changed variables

datapath=/path/to/reads
temp=/path/to/temp/folder
output=/path/to/output/folder
REF=/path/to/reference/genome.fa
logfile=/path/to/logfile_log.txt
threads=32
remove_temp=true

#RGInfo

RGID=mod01.7  # Flow cell name and lane
RGLB=G3modc  # Library name
RGPU=HKWH3BBXX.7  # Flow cell code and lane

# path to tools/conda environments
PICARD=~/apps/picard/build/libs/picard.jar # Picard executable 
conda=~/miniconda3/bin/
ATLAS=new_atlas
mem2=mem2
GATK38=GATK38


# Determine whether variables have remained unset

if [[ -z $datapath ]] || [[ -z $temp ]] || [[ -z $output ]] || [[ -z $REF ]] || [[ -z $logfile ]] || [[ -z $threads ]] || [[ -z $remove_temp ]] || [[ -z $RGID ]] || [[ -z $RGLB ]] || [[ -z $RGPU ]]; then
echo "At least one essential variable is missing. Make sure to define the variables before running the script" 
exit 1
fi

# Send errors to log file

exec 3>&1 1>"$logfile" 2>&1
trap "echo 'ERROR: An error occurred during execution, check $logfile for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG
set -e

# Process the bam files

for file in "$datapath"/*.veladapt.clean_R1.fastq.gz; do 

# Set variables for next task

filetag=$(basename "$file" ".veladapt.clean_R1.fastq.gz")
filepath="${datapath}/${filetag}"
echo -e "\nMoving to sample $filetag" | tee /dev/fd/3 # tee displays the echo output in the terminal now that stdout is sent to a log file
mkdir -p "$temp/$filetag"
mkdir -p "$output/$filetag"


if [[ $CONDA_DEFAULT_ENV != "base" ]]; then
conda deactivate
fi


source $conda/activate $mem2

bwa-mem2 mem -t $threads $REF ${filepath}.veladapt.clean_R1.fastq.gz ${filepath}.veladapt.clean_R2.fastq.gz > "$temp/$filetag/$filetag.raw.bam"

echo "Mapped reads" | tee /dev/fd/3

java -jar "$PICARD" AddOrReplaceReadGroups \
-I "$temp/$filetag/$filetag.raw.bam" \
-O "$temp/$filetag/$filetag.RG.bam" \
-RGID "$RGID" \
-RGLB "$RGLB" \
-RGPL ILLUMINA \
-RGPU "$RGPU" \
-RGSM "$filetag"

echo "Added read groups" | tee /dev/fd/3

# Filter the reads to remove unmapped and secondary reads and those with a low mapping quality

samtools view -@ $threads -b -F 260 -q 20 "$temp/$filetag/$filetag.RG.bam" -o "$temp/$filetag/$filetag.filtered.bam"

echo "Filtered reads" | tee /dev/fd/3

## Realign around indels

# Sort the reads by position for indel realignment

samtools sort -@ $threads "$temp/$filetag/$filetag.filtered.bam" -o "$temp/$filetag/$filetag.sorted.bam" 2> /dev/null

# Index the bam file for indel realignment

samtools index "$temp/$filetag/$filetag.sorted.bam"

conda deactivate
source $conda/activate $GATK38

gatk3 \
-T RealignerTargetCreator \
-R $REF \
-o "$temp/$filetag/$filetag.intervals" \
-I "$temp/$filetag/$filetag.sorted.bam"

gatk3 \
-T IndelRealigner \
-R $REF \
-targetIntervals "$temp/$filetag/$filetag.intervals" \
-I "$temp/$filetag/$filetag.sorted.bam" \
-o "$temp/$filetag/$filetag.realn.bam"

echo "Realigned around indels" | tee /dev/fd/3

## Merge overlaps

conda deactivate
source $conda/activate $ATLAS

atlas mergeOverlappingReads \
--bam "$temp/$filetag/${filetag}.realn.bam" \
--out "$output/$filetag/$filetag"

echo "Merged overlaps" | tee /dev/fd/3

if $remove_temp; then
rm -r $temp
fi

done

echo -e "\nAll samples processed!" | tee /dev/fd/3
