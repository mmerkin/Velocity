#! /bin/bash

# Frequently changed variables

datapath=
output=
threads=
remove_temp=

add_RG=
PICARD=
RGID=
RGLB=

remove_ctgs=
unplaced=
mtDNA=

## Code



set -e  # Causes the code to abort if there is an error

# Aborts the code if variables aren't set

if [[ -z $datapath ]] || [[ -z $output ]] || [[ -z $threads ]] || [[ -z $remove_temp ]] || [[ -z $add_RG ]]; then
echo "At least one essential variable is missing. Make sure to define the variables before running the script" 
exit 1
fi

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

# Refresh the progress bar after each command has finished running

function update_progress {
  task_number=$((task_number + 1))
  calculate_progress $task_number $tasks_in_total
}

# Process the bam files

for file in "$datapath"/*; do 
# Set variables of sample name and task numbers
filetag=${file##*/}
task_number=0
tasks_in_total=6

echo -e "\nMoving to sample ${filetag}"

mkdir -p "$output/$filetag"

calculate_progress $task_number $tasks_in_total

if $remove_ctgs; then
    tasks_in_total=$((tasks_in_total + 1))
fi

# Add read groups (if enabled), preventing the output from printing, and update the progress bar

if $add_RG; then
  java -jar "$PICARD" AddOrReplaceReadGroups \
  -I "$file/$filetag.sort.bam" \
  -O "$output/$filetag/$filetag.RG.bam" \
  -RGID "$RGID" \
  -RGLB "$RGLB" \
  -RGPL ILLUMINA -RGPU unit1 \
  -RGSM "$filetag" 2> /dev/null
  tasks_in_total=$((tasks_in_total + 1))
  update_progress
# filter out reads based on flags, eg unmapped/secondary using different inputs, depending on whether RGs have been added
  samtools view -@ 32 -b -f 3 -F 2828 -q 20 "$output/$filetag/$filetag.RG.bam" -o "$output/$filetag/$filetag.filtered.bam"
else
  samtools view -@ 32 -b -f 3 -F 2828 -q 20 "$file/$filetag.sort.bam" -o "$output/$filetag/$filetag.filtered.bam"
fi


update_progress

# Sort the reads by name for fixmate input, discarding the stderr output to dev/null so it won't display on the command line

samtools sort -@ 32 -n "$output/$filetag/$filetag.filtered.bam" -o "$output/$filetag/$filetag.sorted.n.bam" 2> /dev/null

update_progress

# Add mate score tags for duplicate removal

samtools fixmate -@ 32 -m "$output/$filetag/$filetag.sorted.n.bam" "$output/$filetag/$filetag.fixmate.bam"

update_progress

# Sort the reads by position for markdup input

samtools sort -@ 32 "$output/$filetag/$filetag.fixmate.bam" -o "$output/$filetag/$filetag.sorted.p.bam" 2> /dev/null

update_progress

if $remove_ctgs; then
    # Remove duplicate reads
    samtools markdup -r -@ 32 "$output/$filetag/$filetag.sorted.p.bam" "$output/$filetag/$filetag.markdup.bam"
    update_progress
    # Remove unwanted contigs
    samtools view -h "$output/$filetag/$filetag.markdup.bam" | grep -v -E "$unplaced|$mtDNA" | samtools view -bS > "$output/$filetag/$filetag.processed.bam"
else
    samtools markdup -r -@ 32 "$output/$filetag/$filetag.sorted.p.bam" "$output/$filetag/$filetag.processed.bam"
fi


# Index the final bam file

samtools index "$output/$filetag/$filetag.processed.bam"

update_progress

# Remove all temporary files

if $remove_temp; then
  rm "$output/$filetag/$filetag.sorted.n.bam" "$output/$filetag/$filetag.fixmate.bam" "$output/$filetag/$filetag.sorted.p.bam" "$output/$filetag/$filetag.filtered.bam" 
  if $add_RG; then
  rm "$output/$filetag/$filetag.RG.bam"
  fi
fi

done

echo -e "\nAll samples processed!"
