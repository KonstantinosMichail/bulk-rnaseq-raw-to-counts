#!/usr/bin/env bash
set -euo pipefail

THREADS=8

GENOME="data/reference/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa"
GTF="data/reference/Saccharomyces_cerevisiae.R64-1-1.63.gtf"
GENOME_DIR="data/reference/star_index"

mkdir -p "$GENOME_DIR"

echo "Building STAR genome index..."

STAR \
    --runMode genomeGenerate \
    --runThreadN "$THREADS" \
    --genomeDir "$GENOME_DIR" \
    --genomeFastaFiles "$GENOME" \
    --sjdbGTFfile "$GTF" \
    --sjdbOverhang 150 \
    --genomeSAindexNbases 10

echo "STAR genome index completed."
