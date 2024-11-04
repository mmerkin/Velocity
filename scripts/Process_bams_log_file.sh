#! /bin/bash

# Variables

datapath=/pub61/florat/velocity/aphantopus_hyperantus/modern_data/00_raw_reads_modc
output=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_test3
threads=32
remove_temp=true

add_RG=true
PICARD=/pub64/mattm/apps/picard/build/libs/picard.jar
RGID=E3modc
RGLB=mod03
logfile=Ah_mode_bamprep.log




# Code

# Aborts the code if variables aren't set

if [[ -z $datapath ]] || [[ -z $output ]] || [[ -z $threads ]] || [[ -z $remove_temp ]] || [[ -z $add_RG ]]  || [[ -z $logfile ]]; then
echo "At least one essential variable is missing. Make sure to define the variables before running the script" 
exit 1
fi


# Send outputs to log file

exec 3>&1 1>"$logfile" 2>&1
trap "echo 'ERROR: An error occurred during execution, check $logfile for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG
set -e

# Process bams

mkdir -p $output

for file in "$datapath"/*sort.bam; do 
filename=${file##*/}
filetag=$(basename "$filename" ".sort.bam")

echo "Moving to sample ${filetag}" | tee /dev/fd/3 # tee displays the echo output in the terminal now that stdout is sent to a log file

sleep 3 # Given the person time to read the sample name

echo "Adding read groups" | tee /dev/fd/3

if $add_RG; then
  java -jar $PICARD AddOrReplaceReadGroups \
  -I $file \
  -O "$output/${filetag}.RG.bam" \
  -RGID $RGID \
  -RGLB $RGLB \
  -RGPL ILLUMINA -RGPU unit1 \
  -RGSM $filetag 2> /dev/null
  tasks_in_total=$((tasks_in_total + 1))
  echo "Filtering by flags" | tee /dev/fd/3
  samtools view -@ 32 -b -f 3 -F 2828 -q 20 "$output/${filetag}.RG.bam" -o "$output/${filetag}.filtered.bam"
else
  echo "Filtering by flags" | tee /dev/fd/3
  samtools view -@ 32 -b -f 3 -F 2828 -q 20 $file -o "$output/${filetag}.filtered.bam"
fi

echo "Sorting by name" | tee /dev/fd/3

samtools sort -@ 32 -n "$output/${filetag}.filtered.bam" -o "$output/${filetag}.sorted.n.bam"

echo "Adding mate score tag" | tee /dev/fd/3

samtools fixmate -@ 32 -m "$output/${filetag}.sorted.n.bam" "$output/${filetag}.fixmate.bam"

echo "Sorting by position" | tee /dev/fd/3

samtools sort -@ 32 "$output/${filetag}.fixmate.bam" -o "$output/${filetag}.sorted.p.bam"

echo "Removing duplicate reads" | tee /dev/fd/3

samtools markdup -r -@ 32 "$output/${filetag}.sorted.p.bam" "$output/${filetag}.markdup.bam"

echo "Indexing output bam" | tee /dev/fd/3

samtools index "$output/${filetag}.markdup.bam"

if $remove_temp; then
  rm "$output/${filetag}.sorted.n.bam" "$output/${filetag}.fixmate.bam" "$output/${filetag}.sorted.p.bam" "$output/${filetag}.filtered.bam" "$output/${filetag}.RG.bam"
fi

done

echo "All samples processed!" | tee /dev/fd/3
