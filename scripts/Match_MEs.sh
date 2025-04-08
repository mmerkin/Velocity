#!/bin/bash

A_urticae_path="A_urticae_merian_elements.tsv"
input_path="A_agestis_merian_elements.tsv"

match_MEs() {

# Create the table header
echo -e "ME\tCHROM\tStart\tEnd\tDirection"

  # Loop through M1-M31
  for i in {1..31}; do
    ME="M$i"
    
    # Find the modal chromosome for the current ME
    modal_chr=$(awk -v me="$ME" '$2 == me {print $3}' ${A_urticae_path} | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
    
    # Find busco gene at the first position in Aglais urticae
    first_gene_pos=$(awk -v me="$ME" -v mode="$modal_chr" '$2 == me && $3 == mode {print $4}' ${A_urticae_path} | sort -n | head -n 1)
    first_gene_name=$(awk -v me="$ME" -v mode="$modal_chr" -v target_gene="$first_gene_pos" '$2 == me && $3 == mode && $4 == target_gene {print $1}' ${A_urticae_path})
    # Find busco gene at the final position in Aglais urticae
    last_gene_pos=$(awk -v me="$ME" -v mode="$modal_chr" '$2 == me && $3 == mode {print $4}' ${A_urticae_path} | sort -nr | head -n 1)
    last_gene_name=$(awk -v me="$ME" -v mode="$modal_chr" -v target_gene="$last_gene_pos" '$2 == me && $3 == mode && $4 == target_gene {print $1}' ${A_urticae_path})
    
    # Calculate output table rows 
    output_chr=$(awk -v first_gene="$first_gene_name" '$1 == first_gene {print $3}' ${input_path})
    output_first=$(awk -v first_gene="$first_gene_name" '$1 == first_gene {print $4}' ${input_path})
    output_last=$(awk -v last_gene="$last_gene_name" '$1 == last_gene {print $5}' ${input_path})
    
    # Check that gene is present
    if [ -z "$output_first" ]; then
    output_first="NA"
    fi
    if [ -z "$output_last" ]; then
    output_last="NA"
    fi
    
    # Determine direction of the ME
    if [[ "$output_first" != "NA" && "$output_last" != "NA" ]]; then
      if [ "$output_first" -lt "$output_last" ]; then
        direction="forward"
      else
        direction="reverse"
      fi
    else
      direction="NA"
    fi
    
    # Add the output table rows
    echo -e "$ME\t$output_chr\t$output_first\t$output_last\t$direction"
    
  done

  # Repeat for MZ
  modal_chr_MZ=$(awk '$2 == "MZ" {print $3}' ${A_urticae_path} | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
  
    first_gene_pos=$(awk -v me="MZ" -v mode="$modal_chr_MZ" '$2 == me && $3 == mode {print $4}' ${A_urticae_path} | sort -n | head -n 1)
    first_gene_name=$(awk -v me="MZ" -v mode="$modal_chr_MZ" -v target_gene="$first_gene_pos" '$2 == me && $3 == mode && $4 == target_gene {print $1}' ${A_urticae_path})

    last_gene_pos=$(awk -v me="MZ" -v mode="$modal_chr_MZ" '$2 == me && $3 == mode {print $4}' ${A_urticae_path} | sort -nr | head -n 1)
    last_gene_name=$(awk -v me="MZ" -v mode="$modal_chr_MZ" -v target_gene="$last_gene_pos" '$2 == me && $3 == mode && $4 == target_gene {print $1}' ${A_urticae_path})
    

    output_chr=$(awk -v first_gene="$first_gene_name" '$1 == first_gene {print $3}' ${input_path})
    output_first=$(awk -v first_gene="$first_gene_name" '$1 == first_gene {print $4}' ${input_path})
    output_last=$(awk -v last_gene="$last_gene_name" '$1 == last_gene {print $5}' ${input_path})

    if [ -z "$output_first" ]; then
    output_first="NA"
    fi
    if [ -z "$output_last" ]; then
    output_last="NA"
    fi

    if [[ "$output_first" != "NA" && "$output_last" != "NA" ]]; then
      if [ "$output_first" -lt "$output_last" ]; then
        direction="forward"
      else
        direction="reverse"
      fi
    else
      direction="NA"
    fi
    
    echo -e "MZ\t$output_chr\t$output_first\t$output_last\t$direction"
}

match_MEs


