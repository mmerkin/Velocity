#! /bin/bash

# Useage: bash Count_alt_alleles.sh VCF/VCF.gz OUTPUT

file=$1
output=$2

[[ "$file" == *.gz ]] && cmd="zcat" || cmd="cat"

$cmd $file | awk -v OFS="\t" -v FS="\t" '

## Skip meta info
/^##/ { next }

# Get sample names

/^#CHROM/ {
  for(i=10; i<=NF; i++) {
    samples[i-9] = $i;
    # Initialise genotype counts
    count_00[i-9] = 0;
    count_01[i-9] = 0;
    count_11[i-9] = 0;
  }
  next
}

{
  # Find GT in FMT field
  n = split($9, fmt, ":");
  gt_idx=0
    for(i=1; i<=n; i++) {
      if(fmt[i] == "GT") {
        gt_idx = i;
        break;
      }
    }
    # Skip if no GT
    if(gt_idx == 0) next;

    for(i=10; i<=NF; i++) {
      split($i, sample_fields,  ":");
      gt=sample_fields[gt_idx];

      # skip if genotype is missing
      if(gt == "./." || gt == ".|.") continue;

      # convert phased genotypes to unphased 
      g = gt;
      g = gensub(/\|/, "/", "g", g);

      # split alleles
      split(g, alleles, "/");
      # skip missing alleles
      if(alleles[1] == "." || alleles[2] == ".") continue;

      # sort heteozygous alleles
      if(alleles[1] > alleles[2]) {
        tmp_allele = alleles[1];
        allleles[1] = alleles[2];
        allleles[2] = tmp_allele;
      }
      new_gt = alleles[1] "/" alleles[2];
      if(new_gt == "0/0") count_00[i-9]++;
      else if(new_gt == "0/1") count_01[i-9]++;
      else if(new_gt == "1/1") count_11[i-9]++;
    }
}

END {
  print "Sample", "0/0", "0/1", "1/1";
  for(i=1; i<=length(samples); i++) {
    print samples[i], count_00[i], count_01[i], count_11[i];
  }
}' > $output

# Calculate heterozygosities using the output table

cat $output | awk -v OFS="\t" -v FS="\t" '
# Create new header
BEGIN {
  print "Sample", "Fraction_alt"
}
# Skip previous header 
NR > 1 {
# Calculate heterozygous fraction
sum = 2 * ($2 + $3 + $4);
het = (2* $3 + $4) / sum;
print $1, het
}'
