#!/usr/bin/env bash
set -euo pipefail

THREADS=8
ACCESSIONS="SRR_Acc_List.txt"
OUTDIR="data/fastq"

mkdir -p "$OUTDIR"

while read -r srr; do
    echo "Downloading $srr..."

    fasterq-dump "$srr" \
        --split-files \
        --threads "$THREADS" \
        --outdir "$OUTDIR"

done < "$ACCESSIONS"

echo "Read download completed."
