#/!/bin/bash
#useage bash cutadapters.sh R1.fastq.gz

r1=$1
r2=${1%R1*fastq.gz}"R2*fastq.gz"
OUTFILE=${1%[.,_]R1*fastq.gz}

FILE=$(echo ${OUTFILE}| awk -F/ '{print $NF}')
NAME=$(echo ${FILE} | grep -o -i -E "[A-Z]{2,4}-[0-9]{2}-[0-9]{4}-[0-9]{2,3}")

BARCODE=$(python findbarcode.py ${r1})

echo $OUTFILE
echo $NAME
echo $BARCODE

if [[ -z "$BARCODE" ]]; then
        echo "WARNING-Barcode empty"
        echo ${r1} >> cutadapter_problems.txt
else
        ADAPTERS=velocity-${BARCODE}_adapters.fa
        echo $ADAPTERS
        echo $r1
        echo $r2
        trimmomatic PE -trimlog ${OUTFILE}.veladapt.trim.log \
        -phred33 ${r1} ${r2} ${OUTFILE}.veladapt.clean_R1.fastq.gz \
        ${OUTFILE}.veladapt.discard_R1.fastq.gz \
        ${OUTFILE}.veladapt.clean_R2.fastq.gz \
        ${OUTFILE}.veladapt.discard_R2.fastq.gz \
        ILLUMINACLIP:${ADAPTERS}:2:30:8:1:True \
        LEADING:20 \
        TRAILING:20 \
        SLIDINGWINDOW:4:20 \
        MINLEN:20 \
        AVGQUAL:20
fi
