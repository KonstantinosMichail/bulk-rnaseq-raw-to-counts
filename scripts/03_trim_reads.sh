#!/usr/bin/env bash
set -euo pipefail

THREADS=8

mkdir -p data/trimmed

for r1 in data/fastq/*_1.fastq; do

    sample=$(basename "$r1" _1.fastq)
    r2="data/fastq/${sample}_2.fastq"

    echo "Trimming ${sample}..."

    trimmomatic PE \
        -threads "$THREADS" \
        -phred33 \
        "$r1" "$r2" \
        "data/trimmed/${sample}_R1_paired.fastq.gz" \
        "data/trimmed/${sample}_R1_unpaired.fastq.gz" \
        "data/trimmed/${sample}_R2_paired.fastq.gz" \
        "data/trimmed/${sample}_R2_unpaired.fastq.gz" \
        SLIDINGWINDOW:4:20 \
        MINLEN:36

done

echo "Read trimming completed."
