#! /bin/bash

# Frequently changed variables

datapath=/pub61/florat/velocity/aphantopus_hyperantus/modern_data/00_raw_reads_modc
output=/pub64/mattm/velocity/sequence_files/Aphantopus_hyperantus/modc_test3
threads=32
remove_temp=true
add_RG=true

PICARD=/pub64/mattm/apps/picard/build/libs/picard.jar
RGID=E3modc
RGLB=mod03





## Code



set -e  # Causes the code to abort if there is an error

## Progress bar

# Set progress bar parameters

bar_size=40
bar_char_done="#"
bar_char_todo="-"
bar_percentage_scale=2

function calculate_progress {
    current="$1"
    total="$2"

    # Calculate the percentage progress 
    percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total" )
    # Calculate the widths of the done and todo sub-bars
    done=$(bc <<< "scale=0; $bar_size * $percent / 100" )
    todo=$(bc <<< "scale=0; $bar_size - $done" )

    # build the done and todo sub-bars
    done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")

    # output the bar
    echo -ne "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%"
}

function update_progress {
  task_number=$((task_number + 1))
  calculate_progress $task_number $tasks_in_total
}

## Process the bam files

mkdir -p $output

for file in "$datapath"/*sort.bam; do 
# Set variables of sample name and task numbers
filename=${file##*/}
filetag=$(basename "$filename" ".sort.bam")
task_number=0
tasks_in_total=6

echo -e "\nMoving to sample ${filetag}"

calculate_progress $task_number $tasks_in_total

# Add read groups (if enabled), preventing the output from printing, and update the progress bar

if $add_RG; then
  java -jar $PICARD AddOrReplaceReadGroups \
  -I $file \
  -O "$output/${filetag}.RG.bam" \
  -RGID $RGID \
  -RGLB $RGLB \
  -RGPL ILLUMINA -RGPU unit1 \
  -RGSM $filetag 2> /dev/null
  tasks_in_total=$((tasks_in_total + 1))
  update_progress
# filter out reads based on flags, eg unmapped/secondary using different inputs depending on whether RGs have been added
  samtools view -@ 32 -b -f 3 -F 3852 "$output/${filetag}.RG.bam" -o "$output/${filetag}.filtered.bam"
else
  samtools view -@ 32 -b -f 3 -F 3852 $file -o "$output/${filetag}.filtered.bam"
fi


update_progress

samtools sort -@ 32 -n "$output/${filetag}.filtered.bam" -o "$output/${filetag}.sorted.n.bam" 2> /dev/null

update_progress

samtools fixmate -@ 32 -m "$output/${filetag}.sorted.n.bam" "$output/${filetag}.fixmate.bam"

update_progress

samtools sort -@ 32 "$output/${filetag}.fixmate.bam" -o "$output/${filetag}.sorted.p.bam" 2> /dev/null

update_progress

samtools markdup -r -@ 32 "$output/${filetag}.sorted.p.bam" "$output/${filetag}.markdup.bam"

update_progress

samtools index "$output/${filetag}.markdup.bam"

update_progress

if $remove_temp; then
  rm "$output/${filetag}.sorted.n.bam" "$output/${filetag}.fixmate.bam" "$output/${filetag}.sorted.p.bam" "$output/${filetag}.filtered.bam" 
  if $add_RG; then
  rm "$output/${filetag}.RG.bam"
  fi
fi

done

echo -e "\nAll samples processed\!"
