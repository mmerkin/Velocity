#! /bin/bash

datapath=/path/to/unmerged_bams
RG_main=""  #RGID

temp=/path/to/modc_merged_temp
output=/path/to/modc_bams

remove_temp=true  # Whether to remove temporary files afterwards
logfile=/path/to/logfile_log.txt

# Conda environment

conda=~/miniconda3/bin/
bamadrrg=bams # Name of conda environment containing bamadrrg 


# Code

# Send outputs to log file

exec 3>&1 1>"$logfile" 2>&1
trap "echo 'ERROR: An error occurred during execution, check $logfile for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG
set -e

echo "Copying original files" | tee /dev/fd/3

for i in $datapath/$RG_main/*/*.bam; do 
filetag=$(basename $i _merged.bam)
mkdir -p $temp/$filetag
cp $i $temp/$filetag/${filetag}.temp.bam
echo "Copied $filetag" | tee /dev/fd/3
done

for i in $temp/*/*.temp.bam; do
filetag=$(basename $i .temp.bam)

echo -e "\nMoving to $filetag" | tee /dev/fd/3
mkdir -p $output/$filetag

# Sort and remove duplicates

samtools sort -@ 32 -n "$temp/$filetag/${filetag}.temp.bam" -o "$temp/$filetag/${filetag}.sorted.n.bam"

echo "Sorted by name" | tee /dev/fd/3

samtools fixmate -@ 32 -m "$temp/$filetag/${filetag}.sorted.n.bam" $temp/$filetag/${filetag}.fixmate.bam

echo "Fixmate completed" | tee /dev/fd/3

samtools sort -@ 32 $temp/$filetag/${filetag}.fixmate.bam -o $temp/$filetag/${filetag}.sorted.p.bam

echo "Sorted by position" | tee /dev/fd/3

samtools markdup -r -@ 32 $temp/$filetag/${filetag}.sorted.p.bam $output/$filetag/${filetag}.bam

echo "Removed duplicates" | tee /dev/fd/3

samtools index $output/$filetag/${filetag}.bam

if $remove_temp; then
  rm -r "$temp/$filetag"
fi

done

echo -e "\nAll samples processed!" | tee /dev/fd/3
