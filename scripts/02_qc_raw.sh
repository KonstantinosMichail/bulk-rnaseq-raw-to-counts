#!/usr/bin/env bash
set -euo pipefail

THREADS=8

mkdir -p qc/fastqc_raw
mkdir -p qc/multiqc_raw

echo "Running FastQC on raw reads..."

fastqc \
    -t "$THREADS" \
    -o qc/fastqc_raw \
    data/fastq/*.fastq

echo "Running MultiQC..."

multiqc \
    qc/fastqc_raw \
    -o qc/multiqc_raw

echo "Raw-read QC completed."
