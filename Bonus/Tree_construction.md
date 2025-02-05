
Download the reference genomes for each species and run busco

```bash
busco -i $REF -o $OUTPUT -m genome -l
```

Then, create a list of all of the single copy buscos shared between each species:

```bash
#!/bin/bash

datapath="/pub64/mattm/busco"
output="Lepidoptera_universal_buscos.txt"


# universal
universal_BUSCOs=()


for species in "$datapath"/*_busco/; do
    # Define the path to the single_copy_busco_sequences directory
    single_copy_path="$species/run_lepidoptera_odb10/busco_sequences/single_copy_busco_sequences"
    echo "Moving to $single_copy_path"
    # Check if the single copy directory exists
    if [[ -d "$single_copy_path" ]]; then
        # List the busco genes of the current species
        current_files=()
        for file in "$single_copy_path"/*.faa; do
            current_files+=("$(basename "$file")")
        done
        # On the first iteration, set the final list as that of the first species
        if [[ ${#universal_BUSCOs[@]} -eq 0 ]]; then
            universal_BUSCOs=("${current_files[@]}")
        else
            # Create a temp array of busco genes found in both the current and previous species
            temp_files=()
            for file in "${universal_BUSCOs[@]}"; do
                if [[ " ${current_files[@]} " =~ " $file " ]]; then
                    temp_files+=("$file")
                fi
            done
            # Replace the final list with the temp array, which removes any non-overlapping genes
            universal_BUSCOs=("${temp_files[@]}")
        fi
    else
    	echo "An error has occurred in $species, missing busco file"
    fi
done

# Output the list of files found in all species
echo "Files found in all species:"
for file in "${universal_BUSCOs[@]}"; do
    echo "$file"
done > $output
```

Afterwards, concatenated each gene together from the same species into a single file 

```bash
#!/bin/bash

datapath="/pub64/mattm/busco"
source="/pub64/mattm/velocity/Phylogeny/Lepidoptera_universal_buscos.txt"
output="/pub64/mattm/velocity/Phylogeny/Concatenated_sequences"

mkdir -p $output

for i in $datapath/*_busco; do
folder="${i##*/}"
species="${folder%*_busco}"
echo "Moving to $species"
echo ">$species" > $output/${species}_cat.fa
while read protein; do
protein_file="$i/run_lepidoptera_odb10/busco_sequences/single_copy_busco_sequences/$protein"
tail -n +2 "$protein_file" >> $output/${species}_cat.fa
done < $source
done
```

Then, join each of these files into a single file and run a global alignment

```
touch Leps_unibusco.msa; for i in *.fa; do cat $i >> Leps_unibusco.msa; echo "" >> Leps_unibusco.msa; done # Note that the 'echo ""' adds a new line between sequences
mafft --auto Leps_unibusco.msa >  Leps_unibusco_aln.fa
```
