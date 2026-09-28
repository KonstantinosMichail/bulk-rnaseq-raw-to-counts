#!/usr/bin/env bash
set -euo pipefail

mkdir -p multiqc_post_alignment

echo "Running MultiQC on STAR alignment results..."

multiqc \
    alignment/ \
    -o multiqc_post_alignment/

echo "Post-alignment QC completed."
