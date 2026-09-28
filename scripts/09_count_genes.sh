#!/usr/bin/env bash
set -euo pipefail

THREADS=8
GTF="data/reference/Saccharomyces_cerevisiae.R64-1-1.63.gtf"
OUTFILE="counts/gene_counts.txt"

mkdir -p counts

echo "Running featureCounts..."

featureCounts \
    -T "$THREADS" \
    -p \
    --countReadPairs \
    -B \
    -C \
    -s 2 \
    -a "$GTF" \
    -o "$OUTFILE" \
    alignment/*.Aligned.sortedByCoord.out.bam

echo "Gene counting completed."
