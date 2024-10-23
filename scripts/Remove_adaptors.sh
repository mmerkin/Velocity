#! /bin/bash

# File used by Flora to trim adaptors, with added comments

# Requirements: trimmomatic, read files, barcodes

# Useage: bash Remove_adaptors.sh read_R1.fastq.gz



# Code

# Creates R2 variable, outfile and print out everything after the final "/"

r1=$1
r2=${1%R1*fastq.gz}"R2*fastq.gz"
OUTFILE=${1%[.,_]R1*fastq.gz}
file=$(echo ${OUTFILE}| awk -F / '{print $NF}')


if [[ ${file} == IS01* ]]
then
	echo "Begins with ISO1"
	NAME=$(echo ${OUTFILE} |awk -F/ '{print $NF}'|sed 's/^[IS01]*//'| sed 's/^[_]//' |awk -F '[_]' '{print$1}' )
else
	NAME=$(echo ${OUTFILE} |awk -F/ '{print $NF}'| sed 's/^[0-9-]*//'| sed 's/^[_]//' |awk -F '[_]' '{print$1}' )
fi

BARCODE=$(grep $NAME /pub61/florat/velocity/velocityadapters/velocity_individual-barcodes.txt| awk '{print$2}'|sed 's/\r$//' )


echo $OUTFILE
echo $NAME
echo $BARCODE

# Checks if the barcode is empty, them trims the adaptors

if [[ -z "$BARCODE" ]]; then
	echo "WARNING-Barcode empty"
else
	ADAPTERS=velocity-${BARCODE}_adapters.fa
	echo $ADAPTERS
	echo $r1
	echo $r2
	trimmomatic PE -trimlog ${OUTFILE}.veladapt.trim.log -phred33 ${r1} ${r2} ${OUTFILE}.veladapt.clean_R1.fastq.gz ${OUTFILE}.veladapt.discard_R1.fastq.gz ${OUTFILE}.veladapt.clean_R2.fastq.gz ${OUTFILE}.veladapt.discard_R2.fastq.gz ILLUMINACLIP:/pub61/florat/velocity/velocityadapters/${ADAPTERS}:2:30:8:1:True LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:20 AVGQUAL:20
fi
