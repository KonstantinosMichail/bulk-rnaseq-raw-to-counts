#!/usr/bin/env bash
set -euo pipefail

THREADS=8
GENOME_DIR="data/reference/star_index"
GTF="data/reference/Saccharomyces_cerevisiae.R64-1-1.63.gtf"
OUTDIR="alignment"

mkdir -p "$OUTDIR"

for r1 in data/trimmed/*_R1_paired.fastq.gz; do

    sample=$(basename "$r1" _R1_paired.fastq.gz)
    r2="data/trimmed/${sample}_R2_paired.fastq.gz"

    echo "Aligning ${sample}..."

    STAR \
        --runThreadN "$THREADS" \
        --genomeDir "$GENOME_DIR" \
        --readFilesIn "$r1" "$r2" \
        --readFilesCommand zcat \
        --outFileNamePrefix "${OUTDIR}/${sample}." \
        --outSAMtype BAM SortedByCoordinate \
        --sjdbOverhang 150 \
        --sjdbGTFfile "$GTF"

done

echo "STAR alignment completed."
