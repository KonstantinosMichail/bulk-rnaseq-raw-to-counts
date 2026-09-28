# Bulk RNA-seq: Raw Reads to Differential Expression

An end-to-end bulk RNA-seq analysis workflow for *Saccharomyces cerevisiae*, covering raw sequencing reads through quality control, read trimming, genome alignment, gene-level quantification, and differential expression analysis with DESeq2.

This project was developed as a practical bioinformatics portfolio project to gain hands-on experience with Linux-based RNA-seq processing and R-based statistical analysis.

---

## Project Overview

The workflow starts with publicly available paired-end RNA-seq reads and processes them through a standard bulk RNA-seq pipeline:

```text
Raw FASTQ reads
      ↓
FastQC
      ↓
Read trimming
      ↓
FastQC
      ↓
STAR genome alignment
      ↓
Strandedness assessment
      ↓
Post-alignment QC
      ↓
featureCounts
      ↓
Gene count matrix
      ↓
DESeq2
      ↓
Differential expression
      ↓
MA plot + Volcano plot
```

The project is divided into two main stages:

1. **Command-line RNA-seq processing**

   * FASTQ processing
   * Quality control
   * Trimming
   * Genome indexing
   * Alignment
   * Strandedness assessment
   * Post-alignment QC
   * Gene quantification

2. **Statistical analysis in R**

   * Count matrix preparation
   * Metadata organization
   * Low-count filtering
   * DESeq2 analysis
   * Differential expression
   * Visualization
   * Export of differential expression results

---

## Biological Question

The dataset contains *S. cerevisiae* samples from two strains with different protein production levels.

The analysis compares:

**High protein production vs Low protein production**

The seven samples consist of:

| Strain | Protein production | Replicates |
| ------ | ------------------ | ---------: |
| AAC    | Low                |          4 |
| B184   | High               |          3 |

The primary differential expression comparison was therefore:

```text
B184 / High production
            vs
AAC / Low production
```

---

## Important Experimental Limitation

Protein production and strain are completely confounded in this dataset:

```text
AAC  → Low
B184 → High
```

Therefore, the experiment does **not** contain both strains at both production levels.

Consequently, the differential expression analysis cannot statistically distinguish:

* an effect caused by strain, from
* an effect associated with protein production.

The results should therefore be interpreted as **gene expression differences between the B184/high-production and AAC/low-production groups**, rather than as an independently controlled causal effect of protein production.

This is an important limitation of the dataset and is explicitly considered in the interpretation of the results.

---

## Dataset

The analysis uses seven paired-end RNA-seq samples:

```text
SRR11349420
SRR11349421
SRR11349422
SRR11349423
SRR11349436
SRR11349437
SRR11349438
```

Sample information is stored in:

```text
metadata.tsv
```

The accession list used for read acquisition is stored in:

```text
SRR_Acc_List.txt
```

---

## Reference Genome and Annotation

The *Saccharomyces cerevisiae* reference used for alignment and quantification was:

```text
Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa
```

with the corresponding annotation:

```text
Saccharomyces_cerevisiae.R64-1-1.63.gtf
```

The STAR genome index was generated from these reference files.

---

# Pipeline

## 1. Download sequencing reads

SRA accessions were converted to FASTQ files using `fasterq-dump`.

The paired-end reads were stored under:

```text
data/fastq/
```

The corresponding script is:

```text
scripts/01_download_reads.sh
```

---

## 2. Quality control of raw reads

Raw reads were examined using:

* FastQC
* MultiQC

FastQC was used to inspect individual sequencing files, while MultiQC was used to summarize the QC results.

The corresponding script is:

```text
scripts/02_qc_raw.sh
```

Output directories:

```text
qc/fastqc_raw/
qc/multiqc_raw/
```

---

## 3. Read trimming

Paired-end reads were trimmed using Trimmomatic.

The trimming parameters were:

```text
SLIDINGWINDOW:4:20
MINLEN:36
```

Paired and unpaired reads were generated, with the paired reads used for downstream alignment.

The corresponding script is:

```text
scripts/03_trim_reads.sh
```

Trimmed reads were stored under:

```text
data/trimmed/
```

---

## 4. Quality control after trimming

FastQC was run again on the paired trimmed reads, followed by MultiQC.

This allowed comparison of read quality before and after trimming.

The corresponding script is:

```text
scripts/04_qc_trimmed.sh
```

Output directories:

```text
qc/fastqc_trimmed/
qc/multiqc_trimmed/
```

---

## 5. STAR genome index

A STAR genome index was generated using the *S. cerevisiae* reference genome and GTF annotation.

The index incorporated splice-junction information from the GTF annotation.

The corresponding script is:

```text
scripts/05_build_star_index.sh
```

The generated STAR index is stored under:

```text
data/reference/star_index/
```

---

## 6. Read alignment

Trimmed paired-end reads were aligned to the reference genome using STAR.

Important alignment settings included:

```text
8 threads
paired-end input
gzip decompression with zcat
coordinate-sorted BAM output
sjdbOverhang = 150
```

The corresponding script is:

```text
scripts/06_align_reads.sh
```

Alignment outputs include:

* coordinate-sorted BAM files
* BAM index files
* STAR alignment logs
* splice-junction output

Alignment results are stored under:

```text
alignment/
```

---

## 7. Strandedness assessment

Library strandedness was assessed using RSeQC's `infer_experiment.py`.

The GTF annotation was converted to BED format for use with RSeQC.

The inferred strandedness was used to determine the appropriate `featureCounts` strandedness parameter.

The final featureCounts analysis used:

```text
-s 2
```

The corresponding script is:

```text
scripts/07_check_strandedness.sh
```

The RSeQC environment was created using Conda with RSeQC and BEDOPS.

---

## 8. Post-alignment quality control

MultiQC was run on the STAR alignment results to summarize alignment-related metrics.

The corresponding script is:

```text
scripts/08_post_alignment_qc.sh
```

The report is generated under:

```text
multiqc_post_alignment/
```

---

## 9. Gene-level quantification

Gene-level read counts were generated from the coordinate-sorted BAM files using `featureCounts`.

The analysis used:

```text
8 threads
paired-end counting
--countReadPairs
-B
-C
-s 2
```

The *S. cerevisiae* GTF annotation was used for gene assignment.

The corresponding script is:

```text
scripts/09_count_genes.sh
```

The resulting count matrix is:

```text
counts/gene_counts.txt
```

The featureCounts summary is:

```text
counts/gene_counts.txt.summary
```

The resulting matrix contained:

```text
7,127 genes × 7 samples
```

---

# Differential Expression Analysis

The downstream statistical analysis was performed in R using:

* DESeq2
* ggplot2

The analysis script is:

```text
analysis.R
```

---

## 1. Count matrix preparation

The featureCounts output contains six annotation columns before the sample count columns:

```text
Geneid
Chr
Start
End
Strand
Length
```

Only the sample count columns were retained for DESeq2.

Sample names were cleaned to match the accession IDs in `metadata.tsv`.

---

## 2. Count filtering

Genes were retained if they had at least 10 reads in at least 3 samples:

```text
rowSums(count_matrix >= 10) >= 3
```

This resulted in:

```text
7,127 genes before filtering
5,530 genes after filtering
```

---

## 3. DESeq2 model

A DESeq2 dataset was created using:

```r
design = ~ protein_production
```

The reference level was set to:

```text
low
```

Therefore, the reported contrast was:

```text
high vs low
```

The DESeq2 workflow performs:

* library size normalization through size-factor estimation
* dispersion estimation
* negative-binomial model fitting
* Wald statistical testing
* multiple-testing correction using the Benjamini-Hochberg procedure

---

## 4. Differential expression results

The primary DESeq2 result table contains:

| Column           | Description                                            |
| ---------------- | ------------------------------------------------------ |
| `baseMean`       | Mean normalized expression across samples              |
| `log2FoldChange` | Log2 expression difference between high and low groups |
| `lfcSE`          | Standard error of the log2 fold change                 |
| `stat`           | Wald test statistic                                    |
| `pvalue`         | Unadjusted p-value                                     |
| `padj`           | Benjamini-Hochberg adjusted p-value                    |

For this analysis:

* Positive log2 fold change = higher expression in the high-production group
* Negative log2 fold change = higher expression in the low-production group

---

# Differential Expression Results

Using an adjusted p-value threshold of:

```text
padj < 0.05
```

and an effect-size threshold of:

```text
|log2FoldChange| > 1
```

the analysis identified:

```text
259 upregulated genes
89 downregulated genes
348 significant DEGs in total
```

The complete differential expression results are saved as:

```text
results/differential_expression_results.csv
```

The filtered significant DEG table is saved as:

```text
results/significant_DEGs.csv
```

---

# Visualizations

## MA Plot

The MA plot was generated using the DESeq2 `plotMA()` function.

It shows:

* average normalized expression on the x-axis
* log2 fold change on the y-axis

This provides an overview of the relationship between expression level and differential expression.

---

## Volcano Plot

A volcano plot was generated using `ggplot2`.

The plot displays:

* log2 fold change on the x-axis
* `-log10(adjusted p-value)` on the y-axis

The significance thresholds were:

```text
log2FC = ±1
adjusted p-value = 0.05
```

The resulting plot distinguishes:

```text
Up
Down
Not significant
```

---

# Project Structure

```text
bulk-rnaseq-raw-to-counts/
│
├── README.md
├── analysis.R
├── metadata.tsv
├── SRR_Acc_List.txt
│
├── scripts/
│   ├── 01_download_reads.sh
│   ├── 02_qc_raw.sh
│   ├── 03_trim_reads.sh
│   ├── 04_qc_trimmed.sh
│   ├── 05_build_star_index.sh
│   ├── 06_align_reads.sh
│   ├── 07_check_strandedness.sh
│   ├── 08_post_alignment_qc.sh
│   └── 09_count_genes.sh
│
├── docs/
│
├── counts/
│   └── gene_counts.txt
│
├── results/
│   ├── differential_expression_results.csv
│   └── significant_DEGs.csv
│
├── qc/
│
├── alignment/
│
├── data/
│
└── multiqc_post_alignment/
```

Large sequencing, alignment, reference, and intermediate files are not intended to be committed to the Git repository.

---

# Software and Tools

## Command-line tools

* SRA Toolkit
* FastQC
* MultiQC
* Trimmomatic
* STAR
* RSeQC
* BEDOPS
* featureCounts / Subread

## R

* R
* DESeq2
* ggplot2

## Operating environment

The command-line workflow was performed in a Linux environment, with Conda used for the RSeQC environment.

---

# Reproducibility

The workflow is organized into numbered shell scripts so that each major stage can be reproduced independently:

```text
01 → Download reads
02 → Raw-read QC
03 → Read trimming
04 → Trimmed-read QC
05 → STAR index construction
06 → Read alignment
07 → Strandedness assessment
08 → Post-alignment QC
09 → Gene quantification
```

The downstream statistical analysis is contained in:

```text
analysis.R
```

Sample information is defined in:

```text
metadata.tsv
```

The SRA accessions are listed in:

```text
SRR_Acc_List.txt
```

---

# Project Scope

This project focuses on the workflow from raw RNA-seq reads through differential gene expression.

The analysis ends after:

* differential expression testing
* MA visualization
* volcano visualization
* export of complete DESeq2 results
* export of significant DEGs

Functional enrichment, pathway analysis, and GSEA are outside the scope of this project and can be developed as a separate downstream analysis project using the generated differential expression results.

---

# Key Takeaways

This project provided practical experience with an end-to-end bulk RNA-seq workflow, including:

* Linux-based sequencing data processing
* FASTQ quality control
* read trimming
* reference genome preparation
* RNA-seq alignment
* BAM file processing
* library strandedness assessment
* gene-level read quantification
* construction of count matrices
* experimental metadata handling
* DESeq2 differential expression analysis
* statistical filtering
* RNA-seq visualization
* reproducible shell scripting
* interpretation of experimental design limitations

The project also demonstrates an important principle in transcriptomic analysis: **statistical results must be interpreted in the context of the experimental design and potential confounding variables.**



