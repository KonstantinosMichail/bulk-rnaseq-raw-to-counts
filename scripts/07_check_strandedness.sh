#!/usr/bin/env bash
set -euo pipefail

GTF="data/reference/Saccharomyces_cerevisiae.R64-1-1.63.gtf"
BED="data/reference/yeast_genes.bed"

echo "Converting GTF to BED..."

gtf2bed < "$GTF" > "$BED"

echo "Checking library strandedness..."

for bam in alignment/*.Aligned.sortedByCoord.out.bam; do

    echo "----------------------------------------"
    echo "Sample: $bam"
    echo "----------------------------------------"

    infer_experiment.py \
        -r "$BED" \
        -i "$bam"

done
