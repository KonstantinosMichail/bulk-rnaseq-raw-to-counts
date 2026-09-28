#!/usr/bin/env bash
set -euo pipefail

THREADS=8

mkdir -p qc/fastqc_trimmed
mkdir -p qc/multiqc_trimmed

echo "Running FastQC on trimmed reads..."

fastqc \
    -t "$THREADS" \
    -o qc/fastqc_trimmed \
    data/trimmed/*_paired.fastq.gz

echo "Running MultiQC..."

multiqc \
    qc/fastqc_trimmed \
    -o qc/multiqc_trimmed

echo "Trimmed-read QC completed."

