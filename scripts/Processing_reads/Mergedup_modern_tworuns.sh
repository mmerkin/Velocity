#! /bin/bash

datapath=/path/to/unmerged_bams
RG_main="mod03a.1"  # RGID
RG_reseq="mod03d.1"  # RGID for second bam

temp=/path/to/modc_merged_temp
output=/path/to/modc_bams

remove_temp=true
logfile=/path/to/logfile_log.txt

# Conda environment

conda=~/miniconda3/bin/
bamadrrg=bams


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


if [[ $CONDA_DEFAULT_ENV != "base" ]]; then
conda deactivate
fi

source $conda/activate $bamadrrg


# Merge files

echo -e "\nMerging files" | tee /dev/fd/3

for i in $datapath/$RG_reseq/*/*.bam; do
filetag=$(basename $i _merged.bam)
echo "Merging $filetag" | tee /dev/fd/3
bamaddrg \
-b $datapath/$RG_main/$filetag/${filetag}_merged.bam -s $filetag -r $RG_main \
-b $datapath/$RG_reseq/$filetag/${filetag}_merged.bam -s $filetag -r $RG_reseq \
> $temp/$filetag/${filetag}.temp.bam
done

echo "All samples merged" | tee /dev/fd/3

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
