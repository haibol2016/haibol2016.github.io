---
layout: post
title: "A Beginner's Guide to Bulk RNA-seq Data Analysis: From Raw Reads to Gene Set Enrichment"
date: 2026-01-01
categories: [bioinformatics, rna-seq, genomics, data-analysis]
tags: [rna-seq, bulk-rna-seq, single-cell-rna-seq, spatial-transcriptomics, fastqc, fastp, adapter-trimming, star, bigwig, coverage-tracks, qorts, rseqc, qualimap, featurecounts, htseq, expression-quantification, contamination-detection, igv, cleanup-rnaseq, deseq2, batch-effect, combat, svaseq, ruv-seq, visualization, heatmap, sankey-diagram, gsea, fgsea, bioinformatics, tutorial]
author: Haibo Liu, PhD
toc: true
---

## Introduction

Bulk RNA sequencing (RNA-seq) is a powerful transcriptomics technology that enables researchers to measure RNA abundance, a convenient proxy of gene expression levels, across the entire transcriptome. Unlike microarrays, RNA-seq provides a comprehensive, unbiased view of the transcriptome with high sensitivity and dynamic range. This technology has become a cornerstone of modern genomics research, enabling discoveries in disease mechanisms, drug development, and basic biology.

### Applications of Bulk RNA-seq

Bulk RNA-seq has diverse applications in biological and biomedical research:

- **Differential gene expression analysis**: Identifying genes that are significantly up- or down-regulated between experimental conditions (e.g., treated vs. control, diseased vs. healthy)
- **Transcriptome profiling**: Characterizing the complete set of RNA transcripts in a sample qualitively and quantitatively and tell where and when genes are expressed
- **Genome annotation**: Identifying and annotating genes, transcripts, and their structures in newly sequenced genomes or improving existing annotations
- **Alternative splicing analysis**: Detecting and quantifying different transcript isoforms
- **Gene fusion detection**: Identifying chromosomal rearrangements that create fusion genes
- **Expression quantitative trait loci (eQTL) mapping**: Discovering genetic variants that influence gene expression
- **Biomarker discovery**: Finding gene expression signatures associated with disease states or treatment responses
- **Pathway and network analysis**: Understanding how genes interact and function together

### Limitations of Bulk RNA-seq

Despite its power, bulk RNA-seq has important limitations:

- **RNA abundance snapshot, not actual gene expression**: RNA-seq measures RNA abundance at a specific time point, which represents a snapshot of the transcriptome. This reflects the balance between transcription, RNA processing, and degradation, but does not directly measure the actual rate of gene transcription or protein production. RNA abundance is influenced by both transcriptional activity and post-transcriptional regulation (RNA stability, degradation rates), making it an indirect proxy for gene expression rather than a direct measurement.

- **Cell population averaging**: Bulk RNA-seq measures average expression across all cells in a sample, losing information about cellular heterogeneity
- **Inability to detect rare cell populations**: Rare cell types (<5% of the population) may be masked by more abundant cell types
- **Limited resolution for cell type-specific expression**: Cannot distinguish which cell types express which genes in mixed populations
- **Masking of cell-to-cell variation**: Individual cell differences are averaged out
- **Challenges with mixed cell populations**: In tissues with multiple cell types, it's difficult to attribute expression changes to specific cell populations

### Emerging Alternatives

New technologies are addressing some limitations of bulk RNA-seq:

- **Single-cell RNA-seq (scRNA-seq)**: Captures gene expression at the individual cell level, enabling the identification of cellular heterogeneity, rare cell populations, and cell type-specific expression patterns. However, it's more expensive and technically challenging than bulk RNA-seq.

- **Spatial transcriptomics**: Preserves the spatial context of gene expression within tissues, allowing researchers to understand how gene expression varies across tissue regions. This is particularly valuable for understanding tissue architecture and cell-cell interactions.

- **Direct transcription measurement technologies**: While RNA-seq measures RNA abundance (a snapshot), several technologies directly measure transcriptional activity:
  - **GRO-seq (Global Run-On sequencing)**: Measures active transcription by sequencing nascent RNA transcripts labeled during transcription run-on assays. Provides direct measurement of transcription rates and identifies active transcription start sites.
  - **PRO-seq (Precision Run-On sequencing)**: An improved version of GRO-seq with higher resolution, allowing precise mapping of RNA polymerase positions and transcription dynamics.
  - **ChRO-seq (Chromatin Run-On sequencing)**: Combines chromatin accessibility with run-on sequencing to measure transcription while preserving chromatin context, providing insights into the relationship between chromatin state and transcription.

**When to choose bulk vs. single-cell vs. spatial approaches:**

- **Bulk RNA-seq**: Best for well-defined, homogeneous samples, large-scale studies, cost-effective screening, and when average expression is sufficient
- **Single-cell RNA-seq**: Best when cellular heterogeneity is important, rare cell populations need to be identified, or cell type-specific responses are of interest
- **Spatial transcriptomics**: Best when spatial organization matters, tissue architecture is important, or understanding regional expression patterns is the goal

### Experimental Design

Proper experimental design is crucial for obtaining reliable and interpretable RNA-seq results. Several key considerations should be addressed before sample collection and sequencing:

#### Replication

**Biological replication** (independent biological samples) is essential for statistical power and generalizability:
- **Minimum recommendations**: At least 2 biological replicates per condition
- **More replicates**: Provide greater statistical power and ability to detect smaller effect sizes
- **Cost vs. power trade-off**: More replicates are generally more valuable than deeper sequencing per sample

**Technical replication** (same sample sequenced multiple times) is less critical:
- Primarily useful for assessing technical variability
- Generally not necessary if library preparation is consistent
- Resources are better spent on biological replicates

#### Sample Size and Power Analysis

- **Power analysis**: Estimate required sample size based on expected effect sizes, variability, and desired statistical power (typically 80% power, α=0.05)
  - **Recommended tool**: [`RNASeqPower`](https://bioconductor.org/packages/RNASeqPower/) (R package) or [`PROPER`](https://bioconductor.org/packages/PROPER/) (R package) for RNA-seq-specific power analysis
  - These tools account for RNA-seq-specific characteristics (overdispersion, count distributions) and can estimate sample sizes needed to detect differential expression with desired power
- **Effect size considerations**: Smaller fold changes require more replicates
- **Variability**: High biological variability requires more replicates
- **Multiple comparisons**: Account for the number of genes tested when planning sample size

#### Sequencing Depth Recommendations

Sequencing depth (number of reads per sample) is a critical factor affecting both cost and analysis quality:

- **Minimum recommendations**:
  - **Human/mammalian genomes**: 20-30 million reads per sample (single-end) or 15-20 million read pairs (paired-end)
  - **Smaller genomes** (e.g., yeast, bacteria): 5-10 million reads per sample
  - **Lower depth** may be sufficient for highly expressed genes but will miss lowly expressed transcripts

- **Depth vs. replicates trade-off**:
  - **More replicates > deeper sequencing**: Statistical power increases more with additional biological replicates than with deeper sequencing per sample
  - **Recommended strategy**: 3-5 biological replicates at moderate depth (20-30M reads) is generally better than 2 replicates at very high depth (50M+ reads)
  - **Exception**: For detection of very rare transcripts or alternative splicing, deeper sequencing may be necessary

- **Depth requirements by analysis type**:
  - **Differential expression**: 20-30M reads per sample typically sufficient
  - **Alternative splicing**: 30-50M reads per sample recommended
  - **Low-abundance transcripts**: 50M+ reads may be needed
  - **Single-cell RNA-seq**: Much lower depth per cell (10K-100K reads), but many cells needed

- **Cost considerations**:
  - Sequencing costs scale linearly with depth
  - Consider your research question: Do you need to detect lowly expressed genes, or are highly expressed genes sufficient?
  - Power analysis tools can help optimize the balance between depth and replicates for your specific experimental goals

#### Control Groups

- **Appropriate controls**: Essential for meaningful comparisons (e.g., untreated controls, wild-type controls, baseline time points)
- **Negative controls**: Include to detect contamination or technical artifacts
- **Positive controls**: Known differentially expressed genes can validate the experiment

#### Randomization and Blocking

- **Randomization**: Randomize sample processing order to avoid systematic biases
- **Blocking**: Group related samples together (e.g., by batch, date, technician) to account for technical factors and avoid confounding effects
- **Avoiding confounding**: Ensure that experimental conditions are not perfectly correlated with technical factors (e.g., all control samples in one batch, all treated samples in another). Confounding makes it impossible to distinguish biological effects from technical artifacts. For more details, see this [site](https://hbctraining.github.io/Intro-to-rnaseq-fasrc-salmon-flipped/lessons/02_experimental_planning_considerations.html)
- **Balanced design**: Ensure equal representation of conditions across batches/blocks when possible

#### Design Matrix

Plan your experimental design matrix to:
- Clearly define all experimental factors and their levels
- Account for potential confounders (batch, date, etc.)
- Enable proper statistical modeling in downstream analysis
- Document all experimental variables for inclusion in statistical models

### RNA Sample Preparation and Library Construction

The quality of RNA samples and library construction directly impacts sequencing results and downstream analysis success.

#### RNA Extraction

**Methods vary by sample type:**
- **Tissue samples**: Mechanical disruption (homogenization, bead beating) followed by column-based or phenol-chloroform extraction
- **Cell cultures**: Direct lysis with appropriate buffers
- **Blood/plasma**: Specialized kits for low-abundance RNA or cell-free RNA
- **Formalin-fixed paraffin-embedded (FFPE) samples**: Specialized protocols for degraded RNA

**Key considerations:**
- Use RNase-free reagents and equipment
- Work quickly to minimize RNA degradation
- Store samples appropriately (typically -80°C for long-term storage)

#### RNA Quality Assessment

**RIN (RNA Integrity Number)** is a critical quality metric:
- **Scale**: 1-10 (10 = perfect integrity)
- **Minimum recommendations**: 
  - RIN ≥ 7 for most applications
  - RIN ≥ 8 for sensitive analyses (e.g., alternative splicing)
  - Lower RIN may be acceptable for degraded samples (FFPE) with appropriate protocols
- **Assessment tools**: Agilent Bioanalyzer, TapeStation, or similar instruments

**Other quality metrics:**
- **28S/18S rRNA ratio**: Should be ~2:1 for intact total RNA
- **DV200** (percentage of RNA fragments >200 nucleotides): Alternative metric for degraded samples
- **Concentration**: Ensure sufficient RNA for library preparation (typically 100 ng - 1 μg)

#### Library Types

**NOTES:** Remove/block some extremely abundant gene's transcripts, such as hemoglobin RNAs in blood samples to get enough sequencing coverage for many other interesting genes.

**PolyA-selected libraries:**
- Enriches for polyadenylated mRNA
- Removes exetremely abundant rRNA (ribosomal RNA)
- **Best for**: Standard mRNA expression analysis
- **Limitations**: Misses non-polyadenylated transcripts

**rRNA-depleted libraries:**
- Removes ribosomal RNA while retaining other RNA species
- **Best for**: Total RNA analysis, non-coding RNA studies, degraded samples
- **Methods**: RiboZero, RiboMinus, or similar depletion kits

**Total RNA libraries:**
- Includes all RNA species
- **Best for**: Comprehensive transcriptome analysis
- **Considerations**: High rRNA content requires deeper sequencing

#### Stranded vs. Unstranded Libraries

**Stranded libraries:**
- Preserve information about which DNA strand was transcribed
- **Advantages**: 
  - Distinguish overlapping genes on opposite strands
  - Better for alternative splicing analysis
  - More accurate quantification
- **Methods**: dUTP-based, adaptor-based, or other strand-specific protocols

**Unstranded libraries:**
- Do not preserve strand information
- **Use cases**: Simple expression analysis when strand information isn't critical
- **Limitations**: Cannot distinguish overlapping genes on opposite strands

#### Library Preparation Protocols

**Common commercial kits:**
- **Illumina**: TruSeq RNA Library Prep, NEBNext Ultra II
- **Other platforms**: Compatible with various sequencing platforms

**Ultra-low Input kits:**

- **Use case**: When RNA quantity is very limited (<100 ng, down to 10 ng or even single cells)
- **Specialized protocols**: Designed to work with minimal starting material
- **Examples**: 
  - SMART-Seq (Switching Mechanism at 5' End of RNA Template) for single-cell or low-input RNA
  - Ovation RNA-Seq System for low-input samples
  - Clontech SMARTer kits for ultra-low input
- **Considerations**:
  - May have higher technical variability due to amplification steps
  - May introduce amplification biases
  - Require careful quality control
  - May need deeper sequencing to compensate for lower complexity libraries

**Key steps:**
1. **RNA fragmentation**: Break RNA into appropriate sizes (typically 300-400 bp for 150 bp reads)
2. **First-strand cDNA synthesis**: Reverse transcription
3. **Second-strand synthesis**: Create double-stranded cDNA
4. **Adapter ligation**: Add sequencing adapters
5. **PCR amplification**: Enrich for adapter-ligated fragments
6. **Size selection**: Remove fragments outside desired size range
7. **Quality control**: Assess library quality before sequencing

#### Quality Control Before Sequencing

**Library QC metrics:**
- **Concentration**: Ensure sufficient library for sequencing
- **Size distribution**: Should match expected fragment size
- **Adapter dimers**: Should be minimal (can interfere with sequencing)
- **Library complexity**: Assessed through pre-sequencing QC

**Pre-sequencing validation:**
- qPCR or similar methods to verify library quality
- Small test sequencing run (optional but recommended for large studies)
- Check for contamination or adapter issues

#### Best Practices

1. **Standardize protocols**: Use consistent methods across all samples
2. **Document everything**: Record RNA quality metrics, library preparation dates, and any deviations
3. **Include controls**: Process positive and negative controls alongside samples
4. **Minimize batch effects**: Process samples in balanced batches when possible
5. **Store appropriately**: Keep RNA and libraries at appropriate temperatures
6. **Track samples**: Maintain clear sample tracking from collection through sequencing

### Overview of the Analysis Workflow

A typical bulk RNA-seq differential analysis workflow consists of the following steps:

1. **Raw read quality control** (FastQC): Assess the quality of sequencing reads
2. **Adapter trimming** (fastp, Trimmomatic, Trim Galore): Remove adapter sequences if needed
3. **Read alignment** (STAR, HISAT2, etc.): Map reads to a reference genome
4. **Post-alignment quality control** (QoRTs, RSeQC, Qualimap): Assess alignment quality
5. **Expression quantification** (featureCounts): Count reads mapping to genes
6. **Contamination detection**: Identify and address rRNA, genomic DNA, or environmental contamination
7. **Differential expression analysis** (DESeq2, edgeR, limma/voom): Identify significantly changed genes
8. **Functional enrichment analysis** (ORA, GSEA): Understand biological meaning of results

### Prerequisites and Software Requirements

This tutorial assumes you have:

- Basic familiarity with command-line interfaces (bash/shell)
- Access to a Unix-like system (Linux or macOS)
- Basic understanding of RNA-seq concepts
- R programming knowledge (for differential expression and enrichment analysis)
- The following software tools installed and in your PATH:
  - FastQC
  - fastp (or Trimmomatic/Trim Galore)
  - STAR (or HISAT2/GSNAP)
  - samtools
  - featureCounts
  - QoRTs (or RSeQC/Qualimap)
  - R with Bioconductor packages (DESeq2, fgsea, etc.)

### Common File Formats in RNA-seq Analysis

Understanding file formats is essential for RNA-seq analysis. Here's a quick reference:

| Format | Description | When Used | Tools |
|--------|-------------|-----------|-------|
| **FASTQ** | Raw sequencing reads with quality scores | Input for QC and alignment | FastQC, fastp, STAR |
| **SAM** | Text-based alignment format | Human-readable alignment output | Alignment tools, samtools |
| **BAM** | Binary version of SAM (compressed) | Storage-efficient alignment format | samtools, IGV, featureCounts |
| **GTF/GFF3** | Gene annotation files | Reference for alignment and quantification | STAR index, featureCounts |
| **BigWig** | Compressed coverage track | Visualization in genome browsers | STAR, IGV, UCSC Genome Browser |
| **BedGraph** | Uncompressed coverage track | Alternative to BigWig | STAR, conversion tools |
| **Count matrix** | Tab-delimited gene counts | Input for differential expression | DESeq2, edgeR, limma |
| **VCF** | Variant call format | Variant detection (if applicable) | Variant callers |

**Key format details:**

- **FASTQ quality encoding**: Phred scores can be encoded in different formats (Sanger/Illumina 1.8+, Illumina 1.3+, etc.). FastQC automatically detects encoding.
- **BAM vs SAM**: BAM is compressed and indexed for efficient access. Use `samtools view` to convert between formats.
- **GTF vs GFF3**: Both contain gene/transcript annotations. GTF is more commonly used. Ensure your annotation matches your reference genome version.
- **Count matrix format**: Typically tab-delimited with genes as rows and samples as columns. First column usually contains gene IDs.

### Computational Resources and Performance

RNA-seq analysis can be computationally intensive. Here are typical resource requirements:

**Memory (RAM) requirements:**
- **STAR alignment**: 
  - Human genome: ~30-40 GB RAM for indexing, ~16-32 GB for alignment
  - Smaller genomes (mouse, etc.): ~16-24 GB for indexing, ~8-16 GB for alignment
  - Can be reduced with `--limitGenomeGenerateRAM` option
- **featureCounts**: ~4-8 GB RAM typically sufficient
- **DESeq2/R analysis**: ~4-16 GB depending on dataset size
- **FastQC**: Minimal memory requirements (~1-2 GB)

**CPU requirements:**
- **STAR**: Highly parallelizable, benefits from multiple cores (8-16 cores recommended)
- **featureCounts**: Can use multiple threads with `-T` option
- **Most tools**: Benefit from multi-core systems

**Storage requirements:**
- **Raw FASTQ files**: ~1-3 GB per sample (compressed)
- **BAM files**: ~2-5 GB per sample (uncompressed, can be compressed)
- **Index files**: ~30-50 GB for human genome (STAR index)
- **Intermediate files**: Plan for 2-3x the size of raw data

**Performance tips:**
- Use compressed formats (BAM instead of SAM, gzipped FASTQ)
- Parallelize when possible (process multiple samples simultaneously)
- Consider cloud computing (AWS, Google Cloud, Azure) for large datasets
- Use cluster computing (SLURM, PBS) for institutional resources
- Monitor disk space regularly - RNA-seq data can accumulate quickly

---

## Section 1: Raw Read Quality Control (FastQC)

Quality control is the first and crucial step in any RNA-seq analysis. FastQC is a widely used tool that provides a comprehensive quality assessment of raw sequencing reads before alignment.

### Introduction to FastQC

FastQC generates a detailed HTML report with multiple quality metrics, helping you identify potential issues with your sequencing data. It examines various aspects of read quality, including base quality scores, sequence composition, adapter contamination, and more.

### Running FastQC on Raw Reads

For single-end reads:

```bash
# Basic FastQC command for single-end reads
fastqc sample_R1.fastq.gz -o output_directory/

# With thread and memory options
fastqc sample_R1.fastq.gz -o output_directory/ \
      -t 4 \                    # Number of threads (default: 1)
      --memory 4000              # Memory limit in MB (default: 250)

# Process multiple files
fastqc *.fastq.gz -o qc_reports/ -t 8
```

For paired-end reads:

```bash
# FastQC processes each file separately
fastqc sample_R1.fastq.gz sample_R2.fastq.gz -o output_directory/ \
      -t 4 \                    # Number of threads
      --memory 512              # Memory limit in MB
```

FastQC will generate HTML reports and a zip file containing the data for each input file. See [example reports](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

### Interpreting FastQC Reports

FastQC provides several key metrics:

#### Per Base Sequence Quality

This plot shows the quality scores (Phred scores) at each position along the reads. Quality scores indicate the probability of an incorrect base call:

- **Good quality**: Scores above 28 (green region), indicating <0.16% error rate
- **Warning**: Scores between 20-28 (yellow region)
- **Fail**: Scores below 20 (red region), indicating >1% error rate

**What to look for:**
- Quality should remain high throughout the read
- Degradation at the 3' end is common in RNA-seq but should be minimal
- Consistent quality across all positions is ideal

#### Per Sequence Quality Scores

This shows the distribution of mean quality scores per read. Most reads should have high mean quality scores (>28).

**What to look for:**
- A single peak at high quality indicates good overall sequencing
- Multiple peaks or a peak at low quality suggests problems

#### Per Base Sequence Content

Shows the proportion of each base (A, T, G, C) at each position. In RNA-seq, you may see some bias at the beginning of reads due to random hexamer priming.

**What to look for:**
- Base proportions should reflect the GC content of coding regions for your species (after the first few bases, which may show random hexamer priming bias)
- For most species, coding regions have GC content between 40-60%, so you should see roughly balanced base composition. More accurately, A% = T% and G% = C%
- Strong bias throughout the read that doesn't match expected species GC content may indicate contamination or adapter issues

#### Per Sequence GC Content

Shows the distribution of GC content across all reads. This should form a normal distribution centered around the expected GC content for your organism.

**What to look for:**
- A normal distribution centered on the expected GC content
- Multiple peaks may indicate contamination with sequences from different organisms
- Skewed distributions may indicate technical issues (sequencing artifacts)

#### Sequence Length Distribution

Shows the distribution of read lengths. All reads should be the same length (unless you're using variable-length reads).

**What to look for:**
- Consistent read lengths
- Unexpected length variations may indicate adapter contamination or sequencing issues

#### Sequence Duplication Levels

Shows the percentage of sequences that appear multiple times. High duplication can indicate:

- PCR over-amplification
- Low complexity libraries
- Over-sequencing (sequencing the same fragments multiple times)

**What to look for:**
- Some duplication is normal, especially for highly expressed genes
- Very high duplication (>70%) may indicate problems

#### Overrepresented Sequences

Identifies sequences that appear more frequently than expected. These are often:

- Adapter sequences
- Contamination
- Highly expressed transcripts

**What to look for:**
- Check if overrepresented sequences match known adapters

#### Adapter Content

Shows the percentage of adapter sequence at each position. Adapters should only appear at the ends of reads if present.

**What to look for:**
- Adapter content should be minimal (<5%)
- High adapter content (>20%) indicates the need for trimming
- Adapters appearing in the middle of reads suggest poor quality or very short inserts

### Common Quality Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Low quality at 3' end | RNA degradation | Check RNA integrity (RIN score), use fresh samples |
| High adapter content | Short inserts or adapter contamination | Trim adapters using fastp, Trimmomatic, or Trim Galore |
| High duplication | PCR over-amplification or over-sequencing | May need to reduce PCR cycles or sequence less |
| Uneven base composition | Random hexamer bias (normal) or contamination | First few bases may show bias (normal), check for contamination |
| Multiple GC content peaks | Contamination | Identify and remove contaminating sequences |

### Decision Point: When to Trim Adapters

**Trim adapters if:**
- If adapters are present in >20% of reads and account for a significant portion of read length, trimming may be necessary to improve mapping rate, though read aligners can do soft-clipping during alignment
- Overrepresented sequences match known adapters
- Read quality is poor at the ends
- You're working with very short RNA species (e.g., miRNAs)

**You may skip trimming if:**
- Adapter content is <20%
- Reads are long (>75bp) and quality is good
- No overrepresented adapter sequences are detected

---

## Section 2: Adapter Trimming (Conditional)

If FastQC indicates high adapter content or other quality issues, adapter trimming becomes necessary. This step removes adapter sequences, low-quality bases, and short reads that could interfere with alignment.


### Overview of Trimming Tools

Several tools are available for adapter trimming and quality filtering:

| Tool | Language | Speed | Features | Best For |
|------|----------|-------|----------|----------|
| **fastp** | C++ | Very Fast | Auto adapter detection, quality filtering, deduplication | large volume of data |
| **Trimmomatic** | Java | Fast | Highly configurable, flexible | Custom trimming needs |
| **Trim Galore** | Perl (wrapper) | Fast | Auto adapter detection, wrapper around Cutadapt | Easy-to-use, automatic detection |

### fastp (Detailed Example)

fastp is a fast, all-in-one FASTQ preprocessor that performs adapter trimming, quality filtering, and other preprocessing tasks in a single step. If adapter sequences are not provided, fastp can automatically detects and removes adapter sequences. But it is recommended to provide adapter sequences to avoid wrong trimming, especially for miRNA-seq data.

#### Complete Example with Common Options
For more options, see [fastp documentation](https://github.com/OpenGene/fastp)
```bash
fastp -i sample_R1.fastq.gz \
      -I sample_R2.fastq.gz \
      -o trimmed_R1.fastq.gz \
      -O trimmed_R2.fastq.gz \
      --detect_adapter_for_pe  # Explicitly enable for paired-end
      -h fastp_report.html \
      -j fastp_report.json \
      -q 20 \                    # Quality threshold
      -u 30 \                    # Unqualified percent limit
      -l 50 \                    # Minimum length
      --length_required 50 # Maximum read length allowed after trimming (only used for special case)
      --trim_poly_g \            # Trim polyG  (needed for Nextseq data)
      --trim_poly_x \            # Trim polyX
      --correction \             # Enable base correction for paired-end
      --overlap_len_require 10 \ # Minimum overlap length
      --overlap_diff_limit 1 \   # Maximum mismatch in overlap
      -w 4                        # Number of threads
```

#### Output Files Explanation

- **trimmed_R1.fastq.gz / trimmed_R2.fastq.gz**: Trimmed reads
- **fastp_report.html**: HTML report with statistics and plots
- **fastp_report.json**: JSON file with detailed statistics (for programmatic access)

The HTML report includes:
- Before/after quality score distributions
- Adapter trimming statistics
- Length distribution
- Duplication analysis
- Quality filtering statistics

#### Advanced Options

```bash
# Enable base correction for paired-end reads
--correction

# Specify adapter sequences manually
--adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
--adapter_sequence_r2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT

# Disable quality filtering (only trim adapters)
--disable_quality_filtering

# Keep unpaired reads (for paired-end)
--unpaired_paired_output

# Merge overlapping reads
--merge
```

### Brief Mentions of Other Tools

#### Trimmomatic

Trimmomatic is a Java-based tool offering fine-grained control over trimming parameters:

```bash
# list all possible adapter sequences in fasta format in the file: adapters.fa
java -jar trimmomatic.jar PE \
     input_R1.fastq.gz input_R2.fastq.gz \
     output_R1_paired.fastq.gz output_R1_unpaired.fastq.gz \
     output_R2_paired.fastq.gz output_R2_unpaired.fastq.gz \
     ILLUMINACLIP:adapters.fa:2:30:10 \
     LEADING:3 TRAILING:3 \
     SLIDINGWINDOW:4:20 \
     MINLEN:50
```

**Key features:**
- Highly configurable
- Multiple trimming strategies
- Handles both single-end and paired-end data

#### Trim Galore

Trim Galore is a wrapper around Cutadapt that provides automatic adapter detection:

```bash
trim_galore --paired \
            --quality 20 \
            --length 50 \
            sample_R1.fastq.gz sample_R2.fastq.gz
```

**Key features:**
- Automatic adapter detection
- User-friendly interface
- Integrates with FastQC

### Quality Control After Trimming

After trimming, **always re-run FastQC** on the trimmed reads to verify that:

- Adapter content has been reduced
- Quality scores have improved
- Read lengths are appropriate
- No new issues have been introduced

### Best Practices and Recommendations

1. **Always check FastQC before and after trimming** to verify improvement
2. **Be conservative with quality thresholds** - too aggressive filtering may remove valid data
3. **Keep unpaired reads** from paired-end trimming if they're long enough
4. **Document your trimming parameters** for reproducibility
5. **Consider your read length** - very short reads (<25bp) may not align well

---

## Section 3: Read Alignment

After quality control and trimming, reads must be aligned (mapped) to a reference genome or transcriptome. This step determines where each read originated in the genome, enabling downstream quantification and analysis. Transgenes or pathogen sequences and gene annotation can be added to the reference genome and its annotation file when necessary.

### Reference Genome and Annotation Selection

Before alignment, you need to select appropriate reference genome and annotation files. This is a critical decision that affects all downstream analysis.

#### Choosing a Reference Genome

**For human samples:**
- **T2T-CHM13 (T2T v2.0)**: Most complete human genome assembly (2022)
  - Telomere-to-telomere assembly with complete chromosome sequences
  - Fills gaps present in GRCh38 (centromeres, telomeres, segmental duplications)
  - Based on CHM13 cell line (haploid)
  - **Best for**: Research requiring complete genome coverage, studies of repetitive regions, centromeres, telomeres
  - **Considerations**: 
    - Newer assembly, so some tools/annotations may not yet support it
    - Annotation resources (GENCODE, Ensembl) are being developed but may be less mature
    - May require more computational resources
  - Available from: [NCBI](https://www.ncbi.nlm.nih.gov/assembly/GCA_009914755.4/), [T2T Consortium](https://github.com/marbl/CHM13)
- **GRCh38 (hg38)**: Current standard, recommended for most analyses
  - More complete and accurate than GRCh37
  - Better representation of alternative haplotypes
  - Well-supported by tools and annotation databases
  - Available from: [NCBI](https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.39/), [Ensembl](https://www.ensembl.org/Homo_sapiens/Info/Index), [GENCODE](https://www.gencodegenes.org/human/)
  - **Best for**: Most standard RNA-seq analyses, compatibility with existing resources
- **GRCh37 (hg19)**: Legacy version, still used in some studies
  - May be required for compatibility with existing datasets
  - Less complete than GRCh38 or T2T-CHM13
  - **Important**: Ensure all tools and annotations use the same genome version
  - **Best for**: Compatibility with older datasets and pipelines

**For other organisms:**
- Check organism-specific databases (Ensembl, NCBI, organism-specific resources)
- Use the most recent, well-annotated assembly
- Consider strain-specific genomes if working with specific strains

**Key considerations:**
- **Version consistency**: Genome, annotation (GTF/GFF), and any pre-built indexes must all match
- **Primary vs. alternative contigs**: Decide if you need alternative haplotypes (usually not necessary for standard RNA-seq)
- **Patch versions**: Minor updates to assemblies; usually safe to use latest patch

#### Annotation File Selection

**Annotation sources:**
- **GENCODE** (human, mouse): High-quality, comprehensive annotations
  - Includes protein-coding and non-coding genes
  - Multiple transcript isoforms per gene
  - Regular updates
  - Recommended for human/mouse studies
- **Ensembl**: Broad species coverage, regularly updated
- **RefSeq**: Curated annotations, often more conservative (fewer isoforms)
- **NCBI**: Official annotations, may lag behind other sources

**File format:**
- **GTF (Gene Transfer Format)**: More commonly used, compatible with most tools
- **GFF3 (General Feature Format version 3)**: Alternative format, some tools prefer GTF

**Version matching:**
- Annotation file must match genome assembly version
- Check release dates and version numbers
- Example: GRCh38.p14 genome should use GENCODE release matching GRCh38

**Download locations:**
- **GENCODE**: https://www.gencodegenes.org/
- **Ensembl**: https://www.ensembl.org/info/data/ftp/index.html
- **NCBI**: https://www.ncbi.nlm.nih.gov/genome/
- **UCSC**: https://hgdownload.soe.ucsc.edu/downloads.html

**Best practices:**
1. Document the exact genome and annotation versions used
2. Download from official sources
3. Verify file integrity (checksums)
4. Keep a record of download dates and versions for reproducibility
5. For multi-species studies, ensure consistent annotation quality across species

### Overview of Alignment Tools

Multiple alignment tools are available, each with different strengths:

| Tool | Type | Speed | Splice-aware | Best For |
|------|------|-------|--------------|----------|
| **STAR** | Aligner | Fast | Yes | Standard RNA-seq, large genomes |
| **HISAT2** | Aligner | Very Fast | Yes | Standard RNA-seq, memory-efficient |
| **GSNAP** | Aligner | Moderate | Yes | Variant-aware alignment |
| **Salmon** | Quasi-mapper | Very Fast | NO | Quantification-focused, transcriptome |
| **Kallisto** | Pseudo-aligner | Very Fast | NO | Quantification-focused, transcriptome |
| **Bowtie2-RSEM** | Aligner/Quantifier | slow | NO | Quantification with uncertainty, transcriptome |

**Key differences:**
- **Aligners** (STAR, HISAT2, GSNAP): Generate BAM files with alignment coordinates. For benchmarking of the three aligners, see [here](doi:10.1038/nmeth.4106.)
- **Quasi-mappers/Pseudo-aligners** (Salmon, Kallisto): Focus on quantification, faster but no BAM output. For best results, use genome-decoyed transcriptome index
- **Bowtie2-Quantifiers** (RSEM): Can work with alignments against transcriptome from Bowtie2 or independently


### STAR Alignment (Detailed Example)

STAR (Spliced Transcripts Alignment to a Reference) is a popular seed-extension aligner that handles spliced alignments efficiently and accurately.

#### Building Genome Index

Before alignment, STAR requires a genome index:

```bash
STAR --runMode genomeGenerate \
     --genomeDir /path/to/genome_index \
     --genomeFastaFiles /path/to/genome.fa \
     --sjdbGTFfile /path/to/annotations.gtf \
     --sjdbOverhang 99 \              # Read length - 1 (for 100bp reads)
     --runThreadN 8
```

**Key parameters:**
- `--genomeDir`: Directory where the index will be created
- `--genomeFastaFiles`: Reference genome FASTA file
- `--sjdbGTFfile`: Gene annotation file (GTF or GFF)
- `--sjdbOverhang`: Should be maximal read length minus 1
- `--runThreadN`: Number of threads

#### Alignment Command

**Single-end reads:**

```bash
STAR --genomeDir /path/to/genome_index \
     --readFilesIn sample.fastq.gz \
     --readFilesCommand zcat \
     --outFileNamePrefix sample_ \
     --outSAMtype BAM SortedByCoordinate \
     --runThreadN 8
```

**Paired-end reads:**

```bash
STAR --genomeDir /path/to/genome_index \
     --readFilesIn sample_R1.fastq.gz sample_R2.fastq.gz \
     --readFilesCommand zcat \
     --outFileNamePrefix sample_ \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --runThreadN 8
```

**Complete example with common options for mammalian RNA-seq read alignment:**

```bash
STAR --genomeDir /path/to/genome_index \
     --readFilesIn sample_R1.fastq.gz sample_R2.fastq.gz \
     --readFilesCommand zcat \
     --outFileNamePrefix sample_ \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --outFilterType BySJout \
     --outFilterMultimapNmax 20 \
     --alignSJoverhangMin 8 \
     --alignSJDBoverhangMin 1 \
     --outFilterMismatchNmax 999 \
     --outFilterMismatchNoverReadLmax 0.04 \
     --alignIntronMin 20 \
     --alignIntronMax 1000000 \
     --alignMatesGapMax 1000000 \
     --outReadsUnmapped Fastx \
     --runThreadN 8
```

#### Output Files Explanation

STAR generates several output files:

- **`sample_Aligned.sortedByCoord.out.bam`**: Sorted BAM file with alignments
- **`sample_Log.final.out`**: Summary statistics (mapping rate, etc.)
- **`sample_Log.out`**: Detailed alignment log
- **`sample_Log.progress.out`**: Progress information
- **`sample_SJ.out.tab`**: Detected splice junctions
- **`sample_Unmapped.out.mate1/2`**: Unmapped reads (if requested)

**Key statistics in Log.final.out:**
- **Uniquely mapped reads %**: Percentage of reads mapping to a single location
- **% of reads mapped to multiple loci**: Reads mapping to multiple locations
- **% of reads unmapped**: Reads that couldn't be aligned
- **% of reads unmapped: too short**: Reads too short to align
- **% of reads unmapped: other**: Other unmapping reasons

#### Generating BigWig Coverage Tracks

BigWig files are useful for visualizing coverage in genome browsers like IGV or UCSC Genome Browser.

**Using STAR's built-in wiggle output:**

```bash
STAR --genomeDir /path/to/genome_index \
     --readFilesIn sample_R1.fastq.gz sample_R2.fastq.gz \
     --readFilesCommand zcat \
     --outFileNamePrefix sample_ \
     --outSAMtype BAM SortedByCoordinate \
     --outWigType wiggle \
     --outWigStrand Stranded \
     --outWigNorm RPM \
     --runThreadN 8
```

**Converting wiggle to bigwig format:**

STAR outputs wiggle files, which need to be converted to bigwig using `wigToBigWig`:

```bash
# First, sort the wiggle file by chromosome and position
sort -k1,1 -k2,2n sample_Signal.Unique.str1.out.wig > sample_sorted.wig

# Convert to bigwig (requires chromosome sizes file)
wigToBigWig sample_sorted.wig chrom.sizes sample.bw
```

**Alternative: Generate bigwig from BAM file**

You can also generate bigwig files directly from BAM files using tools like `bamCoverage` from [deepTools](https://deeptools.readthedocs.io/en/latest/):

```bash
# Install deepTools (if not already installed)
# conda install -c bioconda deeptools

# Generate bigwig with RPKM normalization
bamCoverage -b sample_Aligned.sortedByCoord.out.bam \
            -o sample_RPKM.bw \
            --normalizeUsing RPKM \
            --binSize 10 \
            --smoothLength 50

# Generate bigwig with CPM normalization
bamCoverage -b sample_Aligned.sortedByCoord.out.bam \
            -o sample_CPM.bw \
            --normalizeUsing CPM \
            --binSize 10

# Generate strand-specific bigwig
bamCoverage -b sample_Aligned.sortedByCoord.out.bam \
            -o sample_forward.bw \
            --normalizeUsing RPKM \
            --filterRNAstrand forward

bamCoverage -b sample_Aligned.sortedByCoord.out.bam \
            -o sample_reverse.bw \
            --normalizeUsing RPKM \
            --filterRNAstrand reverse
```

**Normalization options:**
- **RPKM** (Reads Per Kilobase per Million): Normalizes for sequencing depth and gene length
- **CPM** (Counts Per Million): Normalizes only for sequencing depth

**Uses for visualization:**
- **IGV (Integrative Genomics Viewer)**: Load BAM and bigwig files to visualize coverage
- **UCSC Genome Browser**: Upload bigwig files for web-based visualization
- **Publication figures**: Export coverage tracks for manuscripts

#### Parameter Optimization

Key STAR parameters to consider:

- **`--outFilterMultimapNmax`**: Maximum number of multiple alignments (default: 10, increase for repetitive regions)
- **`--outFilterMismatchNmax`**: Maximum mismatches per read (default: 10)
- **`--alignIntronMin` / `--alignIntronMax`**: Minimum/maximum intron length
- **`--alignMatesGapMax`**: Maximum gap between paired-end mates
- **`--twopassMode Basic`**: Two-pass alignment for better splice junction detection
- **more parameter tuning**: see [here](https://pmc.ncbi.nlm.nih.gov/articles/PMC4631051/)

### Brief Mentions of Other Tools

#### [HISAT2](https://daehwankimlab.github.io/hisat2/)

HISAT2 is a fast, memory-efficient, exon-first aligner:

```bash
hisat2 -x genome_index \
       -1 sample_R1.fastq.gz -2 sample_R2.fastq.gz \
       -S sample.sam \
       --threads 8
```

**Best for:** Memory-constrained environments, standard RNA-seq

#### [GSNAP](http://research-pub.gene.com/gmap/)

GSNAP, seed-extension aligner, handles variants and indels well:

```bash
gsnap -d genome_index \
      -D /path/to/genome_dir \
      -v known_variants.vcf \              # Known variants file
      --use-splicing=1 \                   # Enable splice-aware alignment
      --novelsplicing=1 \                  # Detect novel splice sites
      -m 5 \                               # Max mismatches
      -i 2 \                               # Indel penalty
      -w 200000 \                          # Max indel length
      -t 8 \                               # Threads
      sample_R1.fastq.gz sample_R2.fastq.gz
```

**Best for:** Variant-aware alignment, samples with known polymorphisms

#### Salmon

Salmon is a fast quantification tool that doesn't produce BAM files:

```bash
# download reference genome and transcriptome fasta files
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.transcripts.fa.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/GRCm38.primary_assembly.genome.fa.gz

# get decoy genome fasta headers
grep "^>" <(gunzip -c GRCm38.primary_assembly.genome.fa.gz) | cut -d " " -f 1 > decoys.txt
sed -i.bak -e 's/>//g' decoys.txt

# concatenate genome and transcriptome fasta files
cat gencode.vM23.transcripts.fa.gz GRCm38.primary_assembly.genome.fa.gz > gentrome.fa.gz

# generate Salmon index. option `--gencode` is only needed if fasta files are from Gencode
salmon index -t gentrome.fa.gz -d decoys.txt -p 12 -i salmon_index --gencode

# Salmon quantification
salmon quant -i transcriptome_index \
             -l A \
             -1 sample_R1.fastq.gz -2 sample_R2.fastq.gz \
             -o salmon_output \
             --threads 8
```

**Best for:** Fast quantification when BAM files aren't needed

#### Kallisto

Kallisto is an ultra-fast pseudo-aligner:

```bash
kallisto quant -i transcriptome_index \
               -o kallisto_output \
               sample_R1.fastq.gz sample_R2.fastq.gz
```

**Best for:** Very fast quantification, large-scale studies

#### RSEM

RSEM provides quantification with uncertainty estimates using an EM algorithm. It take BAM output generated by Bowtie2, which align reads to the transcriptome:

```bash
rsem-calculate-expression --paired-end \
                          --bowtie2 \
                          sample_R1.fastq.gz sample_R2.fastq.gz \
                          rsem_index \
                          sample_output
```

**Best for:** Quantification with confidence intervals, uncertainty modeling

---

## Section 4: Post-Alignment Quality Control

After alignment, it's crucial to assess the quality of your alignments. Post-alignment QC helps identify issues like poor alignment rates, strand-specificity problems, or contamination that may not have been apparent in raw read QC.

### Overview of Post-Alignment QC Tools

Several tools are available for post-alignment quality assessment:

| Tool | Features | Output | Best For |
|------|----------|--------|----------|
| **QoRTs** | Comprehensive RNA-seq metrics | HTML reports, R objects | Detailed RNA-seq-specific QC |
| **RSeQC** | Modular, many metrics | Text reports, plots | Flexible, customizable QC |
| **Qualimap** | Interactive reports | HTML reports | User-friendly, comprehensive |

### QoRTs (Detailed Example)

QoRTs (Quality of RNA-seq Tool-set) is specifically designed for RNA-seq data and provides comprehensive quality metrics. QoRTs generates detailed quality control reports including junction annotation, read distribution, gene body coverage, and various quality metrics. It's particularly useful for identifying RNA-seq-specific issues.

#### Running QoRTs on BAM Files

QoRTs requires a sample file that lists all BAM files to be processed along with their metadata. This allows batch processing and proper organization of QC results.

**Sample file format:**

QoRTs accepts a tab-delimited file with sample information. The minimal format requires at least a sample ID and BAM file path:

For more comprehensive analysis and better organization, include additional metadata columns. See example below. 
**Sample file format:**
- One BAM file path per line
- Can use absolute or relative paths
- No header required
- Empty lines are ignored

**Column descriptions:**
- **sampleID**: Unique identifier for each sample (required)
- **bamFile**: Path to the BAM file, can be relative or absolute (required)
- **condition**: Experimental condition (e.g., control, treated) - useful for grouping in QC reports
- **batch**: Sequencing or processing batch - helps identify batch effects
- **replicate**: Replicate number - tracks biological replicates
- **date**: Processing date - useful for tracking temporal effects
- **technician**: Person who processed the sample - identifies technician-specific effects
- **notes**: Additional comments or metadata - free text for any relevant information

**Creating the sample file:**

```bash
# Create sample file manually or programmatically
cat > samples.txt << EOF
sampleID	bamFile	condition	batch	replicate	date	technician	notes
sample1	sample1_Aligned.sortedByCoord.out.bam	control	batch1	rep1	2025-01-15	tech1	Control group
sample2	sample2_Aligned.sortedByCoord.out.bam	control	batch1	rep2	2025-01-15	tech1	Control group
sample3	sample3_Aligned.sortedByCoord.out.bam	treated	batch1	rep1	2025-01-15	tech1	Treated group
sample4	sample4_Aligned.sortedByCoord.out.bam	treated	batch1	rep2	2025-01-15	tech1	Treated group
EOF
```

**Basic command with sample file:**

```bash
java -jar QoRTs.jar QC \
     samples.txt \
     annotations.gtf \
     qc_output_directory/
```

**Single BAM file (alternative method):**

If processing a single file, you can create a minimal sample file:

```bash
# Create sample file for single BAM
cat > single_sample.txt << EOF
sampleID	bamFile
sample1	sample1_Aligned.sortedByCoord.out.bam
EOF

java -jar QoRTs.jar QC \
     single_sample.txt \
     annotations.gtf \
     qc_output_directory/
```

**With additional options:**

```bash
java -jar QoRTs.jar QC \
     --stranded \
     --singleEnded \
     samples.txt \
     annotations.gtf \
     qc_output_directory/
```

#### Interpreting QoRTs Reports

QoRTs generates comprehensive reports with multiple components:

**Junction annotation:**
- Known vs. novel splice junctions
- Junction quality scores
- Junction coverage

**Read distribution:**
- Percentage of reads in exons, introns, intergenic regions
- Strand-specificity assessment
- Expected vs. observed distributions

**Gene body coverage:**
- Coverage uniformity across gene bodies
- 5' to 3' bias detection
- Coverage plots for individual genes

**Quality metrics:**
- Mapping quality scores
- Read length distributions
- Duplication rates
- GC content analysis

### RSeQC (Brief Mention)

RSeQC provides modular quality control with many specific analysis modules:

**Key features:**
- Modular design - run only needed analyses
- Many specialized modules
- Text-based output

**Common modules:**

```bash
# Gene body coverage
geneBody_coverage.py -r annotations.bed -i sample.bam -o output

# Read distribution
read_distribution.py -r annotations.bed -i sample.bam

# Junction saturation
junction_saturation.py -r annotations.bed -i sample.bam -o output
```

**Use cases:**
- Custom QC pipelines
- Specific metric extraction
- Batch processing

### Qualimap (Brief Mention)

Qualimap provides user-friendly, interactive HTML reports:

**Key features:**
- Interactive HTML reports
- RNA-seq specific analysis
- Easy to interpret visualizations

**Usage:**

```bash
qualimap rnaseq \
         -bam sample.bam \
         -gtf annotations.gtf \
         -outdir qualimap_output
```

**Use cases:**
- Quick quality assessment
- Interactive exploration
- Report sharing

### Best Practices for Post-Alignment QC

1. **Check alignment rates**: Should be >70% for most RNA-seq experiments
2. **Assess strand-specificity**: Verify if your library is stranded or unstranded
3. **Examine gene body coverage**: Should be relatively uniform (depending on the library construction protocol)
4. **Check junction annotation**: Verify known vs. novel junctions
5. **Compare across samples**: Look for outliers or batch effects
6. **Document QC metrics**: Keep records for publication and troubleshooting

---

## Section 5: Expression Quantification (featureCounts)

After quality control, the next step is to quantify gene expression by counting reads that map to each gene. This generates a count matrix that serves as input for differential expression analysis.

### Introduction to Expression Quantification

Expression quantification involves counting the number of reads (or fragments for paired-end data) that map to each gene or transcript. These counts serve as a proxy for gene expression levels.

### Overview of Quantification Tools

Two main tools are commonly used for counting reads:

| Tool | Language | Speed | Features |
|------|----------|-------|----------|
| **featureCounts** | C++ | Very Fast | Multi-threading, flexible, part of Subread |
| **HTSeq** | Python | slow | Well-established, Python-based |

### Why featureCounts over HTSeq

featureCounts is generally preferred over HTSeq for several reasons:

- **Performance**: Faster execution, especially for large datasets (often 5-10x faster)
- **Built-in multi-threading support**: Can utilize multiple CPU cores
- **Better handling of multi-mapping reads**: More sophisticated assignment strategies
- **More flexible counting options**: Better overlap resolution, strand-specificity handling
- **Simpler command-line interface**: Easier to use and script
- **Active development and maintenance**: Regularly updated with improvements

### Introduction to featureCounts

featureCounts is part of the Subread package and is designed for counting reads overlapping genomic features (genes, exons, etc.) defined in a GTF/GFF annotation file, or a SAF file.

### Running featureCounts

**Basic command for single-end reads:**

```bash
featureCounts -a annotations.gtf \
              -o counts.txt \
              sample.bam
```

**For paired-end reads:**

```bash
featureCounts -a annotations.gtf \
              -o counts.txt \
              -p \                    # Count fragments (pairs) instead of reads
              sample.bam
```

**Complete example with common options, processing multiple BAM files:**

```bash
featureCounts -a annotations.gtf \
              -o counts.txt \
              -T 8 \                 # Number of threads
              -p \                   # Count fragments for paired-end
              -s 1 \                 # Strand-specific (1 = forward, 2 = reverse, 0 = unstranded)
              -t exon \              # Feature type to count (exon, gene, etc.)
              -g gene_id \           # Attribute to group features
              --primary \            # Count only primary alignments
              -Q 10 \                # Minimum mapping quality
              ample1.bam sample2.bam sample3.bam
```

### Understanding Output Format

featureCounts generates two main output files:

1. **Count matrix file** (e.g., `counts.txt`): Contains gene counts for each sample
2. **Summary file** (e.g., `counts.txt.summary`): Contains alignment statistics

**Count matrix format:**

```
Geneid  Chr Start   End     Strand  Length  sample1.bam  sample2.bam  sample3.bam
Gene1   chr1 1000   5000    +       4000    150          200          180
Gene2   chr1 6000   8000    -       2000    50           45           60
...
```

**Summary file contains:**
- Total reads processed
- Successfully assigned reads
- Unassigned reads (with reasons)
- Ambiguity assignments

### Count Matrix Generation

The count matrix from featureCounts can be directly used as input for differential expression analysis tools like DESeq2 or edgeR. The matrix should have:

- **Rows**: Genes (or features)
- **Columns**: Samples
- **Values**: Read counts (or fragment counts for paired-end)

**Preparing the matrix for DESeq2:**

```r
# Read the count matrix
counts <- read.table("counts.txt", header=TRUE, row.names=1)

# Remove annotation columns, keep only count columns
counts <- counts[, 6:ncol(counts)]  # Adjust based on your file structure

# Ensure column names match sample names
colnames(counts) <- gsub(".bam", "", colnames(counts))
```

### Normalization Methods in RNA-seq

Understanding normalization is crucial for interpreting RNA-seq data. Different normalization methods serve different purposes and are used at different stages of analysis.

#### Why Normalization is Needed

Raw read counts are not directly comparable across samples because:
- **Sequencing depth varies**: Different samples may have different numbers of total reads
- **Gene length varies**: Longer genes naturally accumulate more reads
- **Compositional differences**: Some samples may have higher expression of certain gene classes

#### Common Normalization Methods

**1. RPKM (Reads Per Kilobase per Million mapped reads)**
- **Formula**: (Read count × 10^9) / (Gene length × Total mapped reads)
- **Normalizes for**: Sequencing depth and gene length
- **Use case**: Comparing expression levels of different genes within the same sample
- **Limitation**: Not suitable for comparing across samples (compositional bias)
- **When to use**: Single-sample analysis, visualization

**2. FPKM (Fragments Per Kilobase per Million mapped reads)**
- **Formula**: Similar to RPKM but uses fragments instead of reads (for paired-end data)
- **Normalizes for**: Sequencing depth and gene length
- **Use case**: Same as RPKM, but for paired-end sequencing
- **Limitation**: Same compositional bias issues as RPKM
- **When to use**: Single-sample analysis with paired-end data

**3. TPM (Transcripts Per Million)**
- **Formula**: (Read count × 10^6) / (Gene length × Sum of (read count/gene length) for all genes)
- **Normalizes for**: Sequencing depth and gene length
- **Advantage over RPKM/FPKM**: Sum of TPM values across all genes is constant (1 million), making it more comparable across samples
- **Use case**: Comparing expression levels across samples (better than RPKM/FPKM)
- **When to use**: Cross-sample comparisons, visualization

**4. CPM (Counts Per Million)**
- **Formula**: (Read count × 10^6) / Total mapped reads
- **Normalizes for**: Sequencing depth only (not gene length)
- **Use case**: Quick normalization for visualization, not for statistical analysis
- **When to use**: Preliminary visualization, not for DE analysis

#### DESeq2's Normalization Approach

DESeq2 uses a different normalization strategy that is specifically designed for differential expression analysis:

**Size factors (similar to library size normalization):**
- Estimates a size factor for each sample based on the median ratio of gene counts to a "reference" sample
- Accounts for differences in sequencing depth
- More robust than simple library size normalization because it uses median ratios (less affected by highly expressed genes)

**Why DESeq2 doesn't use RPKM/FPKM/TPM:**
- These methods assume that most genes are not differentially expressed (not always true)
- DESeq2's size factors are estimated from the data and account for the actual distribution of expression
- Designed specifically for count-based statistical models (negative binomial)

**When to use normalized counts from DESeq2:**
- For visualization (heatmaps, PCA plots)
- For comparing expression levels across samples
- **Not for statistical testing** (DESeq2 uses raw counts for DE analysis)

**Example: Getting normalized counts from DESeq2**

```r
# After running DESeq2 analysis
dds <- DESeq(dds)

# Get normalized counts (size-factor normalized)
normalized_counts <- counts(dds, normalized=TRUE)

# These can be used for visualization
# For log transformation (common for visualization):
log_normalized <- log2(normalized_counts + 1)
```

#### Choosing the Right Normalization Method

| Purpose | Recommended Method | Tool |
|---------|-------------------|------|
| **Differential expression analysis** | DESeq2 size factors (internal) | DESeq2, edgeR |
| **Visualization across samples** | DESeq2 normalized counts or TPM | DESeq2, or calculate TPM |
| **Single-sample gene comparison** | RPKM/FPKM | Calculate manually or use tools |
| **Quick visualization** | CPM | Calculate manually |
| **Cross-study comparisons** | TPM (with caution) | Calculate manually |

**Key takeaway**: For differential expression analysis, use tools like DESeq2 or edgeR that handle normalization internally. Don't use RPKM/FPKM/TPM-normalized data as input for DE analysis - these tools need raw counts.

### Contamination Detection Using featureCounts Summary

Quality control doesn't end after alignment. It's crucial to check for various types of contamination that can affect downstream analysis and interpretation.

#### Importance of Contamination Detection

Contamination can lead to:
- Incorrect expression estimates
- False positive differential expression results
- Misinterpretation of biological findings
- Wasted computational resources

#### Using featureCounts Summary Statistics to Identify Contamination

The featureCounts summary file provides valuable information for detecting contamination. Key metrics to examine:

- **Assigned vs. unassigned reads**: High unassigned rates may indicate contamination
- **Ambiguity assignments**: Reads mapping to multiple features
- **Feature type distribution**: Unexpected distributions may signal issues

#### Types of Contamination to Check

##### rRNA Contamination

**What to look for:**
- High percentage of reads mapping to rRNA genes (>5-10% is concerning)
- Expected vs. observed rRNA percentages (should be <5% for polyA-selected libraries)

**Impact on downstream analysis:**
- Reduces usable reads for gene expression analysis
- Can skew normalization
- Wastes sequencing depth

**Solutions:**
- **Prevention**: Perform polyA(+)-RNA selection, or rRNA depletion (RiboZero, etc.) to remove rRNA.
- **Filtering**: Remove rRNA-mapped reads before differential expression analysis (if contamination is detected)

**Checking in featureCounts summary:**
```bash
# Count reads mapping to rRNA features separately
featureCounts -a annotations_with_rRNA.gtf \
              -o counts_with_rRNA.txt \
              sample.bam

# Check the summary file for rRNA assignment percentages
grep "rRNA" counts_with_rRNA.txt.summary
```

##### Host Genomic DNA Contamination

**What to look for:**
- Reads mapping to intergenic regions (high percentage is concerning)
- High percentage of unassigned reads that align to the genome

**Visual inspection using IGV (Integrative Genomics Viewer):**

IGV is invaluable for visually confirming DNA contamination:

1. **Loading BAM files and reference genome:**
   ```bash
   # IGV can be launched and files loaded through the GUI
   # Or use command line:
   igv.sh -g genome.fa sample.bam
   ```

2. **Identifying characteristic patterns of DNA contamination:**
   - **Intron-only reads without exon coverage**: Reads mapping entirely to introns without spanning exons
   - **Reads spanning intron-exon boundaries incorrectly**: Reads that don't follow proper splicing patterns
   - **Intergenic reads**: Reads mapping to regions between genes

3. **What to look for in IGV:**
   - Zoom into gene regions and check for:
     - Reads mapping only to introns
     - Lack of proper exon coverage
     - Unusual read patterns that don't match RNA-seq expectations

**Solutions:**
- **Prevention**: 
  - DNase treatment during RNA extraction
  - PolyA(+) RNA selection (removes most DNA)
- **Rescue**: CleanUpRNAseq package for correcting for genomic DNA contamination

**Using CleanUpRNAseq:**

When genomic DNA contamination is obvious after IGV visualization, [CleanUpRNAseq](https://bioconductor.org/packages/CleanUpRNAseq/) can rescue the data.


##### Environmental Microorganism Contamination

**What to look for:**
- Unexpected alignments to bacterial/fungal genomes
- High percentage of reads that don't align to the reference genome map to non-target organisms

**Detection methods:**
- **BLAST**: Blast unaligned reads against NCBI databases
- **Kraken2**: Taxonomic classification of reads
- **Alignment to multiple genomes**: Align to host + common contaminants

**Solutions:**
- **Sample preparation improvements**: Better sterile technique, contamination controls

**Example with Kraken2:**

```bash
# Classify reads taxonomically
kraken2 --db kraken_db \
        --paired sample_R1.fastq.gz sample_R2.fastq.gz \
        --output classification.txt \
        --report report.txt

# Check for unexpected taxa
grep -v "Homo sapiens" report.txt | head -20
```

#### Interpreting featureCounts Summary Statistics

**Assigned vs. unassigned reads:**
- **Assigned**: Reads successfully counted for a feature (good)
- **Unassigned_Ambiguity**: Reads mapping to multiple features (may need filtering)
- **Unassigned_NoFeatures**: Reads in regions without annotated features (check for contamination)
- **Unassigned_Unmapped**: Reads that didn't align (check alignment quality)

**Ambiguity assignments:**
- High ambiguity may indicate:
  - Overlapping genes
  - Gene families with high similarity
  - Annotation issues

**Feature type distribution:**
- Should match library type:
  - PolyA-selected: Mostly exonic reads
  - Total RNA: Mix of exonic, intronic, intergenic
  - rRNA-depleted: Mostly exonic, some intronic

#### Thresholds and Quality Metrics

**Acceptable contamination levels:**
- **rRNA**: <5% for polyA libraries, <20% for total RNA (depends on depletion efficiency)
- **Genomic DNA**: <1-2% for polyA libraries
- **Environmental**: Should be minimal (<0.1%)

**Warning signs:**
- Unassigned reads >20%
- High intergenic mapping (>5%)
- Unexpected feature type distributions
- Sample-to-sample variation in assignment rates

**When to exclude samples:**
- Contamination >50% of reads
- Severe quality issues that can't be corrected
- Samples that are clear outliers after correction attempts

#### Command-Line Examples for Contamination Analysis

```bash
# Count with detailed feature annotation
featureCounts -a annotations.gtf \
              -o detailed_counts.txt \
              --extraAttributes gene_name,gene_biotype \
              sample.bam

# Check summary statistics
cat detailed_counts.txt.summary

# Extract unassigned reads for further analysis
samtools view -b -F 4 sample.bam | \
samtools view -b -q 10 - | \
bedtools intersect -v -a - -b exons.bed > intergenic_reads.bam

# Count intergenic reads
samtools view -c intergenic_reads.bam
```

#### Best Practices for Contamination Prevention

1. **Use appropriate library preparation methods** for your RNA type
2. **Include negative controls** in your experiment
3. **Monitor QC metrics** at each step
4. **Document contamination levels** in your analysis
5. **Consider contamination in experimental design** (e.g., rRNA depletion for total RNA)
6. **Re-run featureCounts after cleanup** if using rescue methods

---

## Section 6: Differential Expression Analysis

Differential expression analysis identifies genes that are significantly up- or down-regulated between experimental conditions. This is often the primary goal of RNA-seq experiments.

### Overview of DE Tools

Three main tools are commonly used for differential expression analysis:

| Tool | Method | Best For | Features |
|------|--------|----------|----------|
| **DESeq2** | Negative binomial | Most RNA-seq studies | Robust, well-documented, comprehensive |
| **edgeR** | Negative binomial | Similar to DESeq2 | Fast, flexible, good for complex designs |
| **limma/voom** | Linear modeling | Large sample sizes | Fast, powerful for complex designs |

### Batch Effect Considerations

Batch effects are systematic non-biological differences between groups of samples that can confound differential expression analysis. They must be identified and addressed to obtain reliable results.

#### What are Batch Effects and Why They Matter

Batch effects arise from technical variations such as:
- Different library preparation dates
- Different technicians or laboratories
- Different sequencing batches or runs
- Different sequencing instruments or lanes

**Why they matter:**
- Can create false positive differential expression
- Can mask true biological differences
- Can lead to incorrect biological interpretations
- Can reduce statistical power

#### Sources of Batch Effects

Common sources include:
- **Sequencing batch**: Samples sequenced in different batches
- **Date**: Samples processed on different dates
- **Technician**: Different people processing samples
- **Laboratory**: Samples processed in different labs
- **Instrument**: Different sequencing machines
- **Lane effects**: Different flow cell lanes

#### Impact on Differential Expression Results

Batch effects can:
- Create spurious associations between batch and condition
- Reduce power to detect true differences
- Lead to inflated false discovery rates
- Cause clustering by batch instead of condition

#### Detection Methods

**PCA (Principal Component Analysis):**
```r
# After creating DESeqDataSet
vsd <- vst(dds, blind=FALSE)
pcaData <- plotPCA(vsd, intgroup=c("condition", "batch"), returnData=TRUE)
ggplot(pcaData, aes(PC1, PC2, color=condition, shape=batch)) + geom_point()
```

**Hierarchical clustering:**
```r
# Check if samples cluster by batch
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <- as.matrix(sampleDists)
pheatmap(sampleDistMatrix, annotation_col=sample_info)
```

#### Batch Effect Correction Tools

##### ComBat (from sva package)

ComBat uses an empirical Bayes method to adjust for known batch effects. 
Note: Use adjusted counts (convert back if needed) for exploratory analysis only. For differential analysis, include batch as a term in the model.

```r
library(sva)

# Assuming you have normalized counts
# ComBat expects log-transformed data
log_counts <- log2(counts(dds, normalized=TRUE) + 1)

# Adjust for batch
batch <- colData(dds)$batch
condition <- colData(dds)$condition
modcombat <- model.matrix(~condition, data=colData(dds))
combat_counts <- ComBat(dat=log_counts, batch=batch, mod=modcombat)
```

**When to use:** Known batch effects, balanced design

##### SVAseq (Surrogate Variable Analysis)

SVAseq identifies and removes unknown batch effects:

```r
library(sva)

# Identify surrogate variables
mod <- model.matrix(~condition, colData(dds))
mod0 <- model.matrix(~1, colData(dds))
svseq <- svaseq(counts(dds, normalized=FALSE), mod, mod0)

# Check how many surrogate variables were identified
n.sv <- svseq$n.sv
print(paste("Number of surrogate variables:", n.sv))

# Add surrogate variables to design (adjust based on n.sv)
for(i in 1:n.sv) {
  dds[[paste0("SV", i)]] <- svseq$sv[,i]
}
sv_formula <- paste("~condition", paste0("+ SV", 1:n.sv, collapse=""), sep="")
design(dds) <- as.formula(sv_formula)
dds <- DESeq(dds)
```

**When to use:** Unknown batch effects, complex confounding

##### RUV-seq (Remove Unwanted Variation)

RUV-seq uses control genes or replicates to estimate unwanted variation. The `k` parameter specifies the number of unwanted variation factors to estimate and remove:

```r
library(RUVSeq)

# Method 1: Using control genes (e.g., housekeeping genes)
# Select control genes (genes expected to be non-differentially expressed)
control_genes <- rownames(counts)[1:1000]  # Or use known housekeeping genes
# Alternatively, use genes with low variance across samples

# Estimate RUV factors (k can be 1, 2, 3, etc. - choose based on data complexity)
ruv <- RUVg(counts(dds), control_genes, k=2)  # k=2 estimates 2 factors

# Method 2: Using replicate samples
# scIdx should be a list of replicate groups
replicate_groups <- list(rep1=c(1,2), rep2=c(3,4), rep3=c(5,6))  # Example structure
ruv <- RUVs(counts(dds), cIdx=rownames(counts), k=2, scIdx=replicate_groups)

# Choosing k: Start with k=1 and increase if needed
# Can use PCA to estimate number of unwanted variation factors
# Or try different k values and compare results

# Add RUV factors to design
# Determine number of RUV factors (k parameter in RUVg/RUVs)
k <- ncol(ruv$W)  # Number of factors estimated
print(paste("Number of RUV factors:", k))

# Dynamically add all RUV factors
for(i in 1:k) {
  dds[[paste0("W_", i)]] <- ruv$W[,i]
}

# Create design formula with all RUV factors
ruv_formula <- paste("~condition", paste0("+ W_", 1:k, collapse=""), sep="")
design(dds) <- as.formula(ruv_formula)
dds <- DESeq(dds)
```

**When to use:** Control genes available, replicate samples available

**Choosing k (number of RUV factors):**
- Start with `k=1` and increase if batch effects persist
- Use PCA to visualize unwanted variation and estimate k
- Too many factors (high k) may remove biological signal
- Too few factors (low k) may not fully remove unwanted variation
- Typical range: k=1 to k=5, depending on data complexity

#### When to Apply Batch Correction

**Apply batch correction when:**
- PCA shows clear batch clustering
- Batch is confounded with condition
- You have known technical batches
- Statistical tests indicate batch effects

**Consider not applying when:**
- Batch and condition are perfectly balanced
- No evidence of batch effects in QC
- Correction might remove biological signal
- Small sample sizes (correction can be unstable due to lack of degrees of freedom)

#### Integration with DESeq2 Workflow

Batch information can be incorporated into DESeq2 in several ways:

1. **As a covariate in the design:**
```r
design(dds) <- ~ batch + condition
```
2. **Using surrogate variables:**
```r
design(dds) <- ~ SV1 + SV2 + condition
```

### DESeq2 Analysis (Detailed Example)

DESeq2 is a popular tool for differential expression analysis that uses a negative binomial model to account for overdispersion in count data.

#### R Setup and Package Loading

```r
# Install Bioconductor if needed
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install DESeq2
BiocManager::install("DESeq2")

# Load required libraries
library(DESeq2)
library(ggplot2)
library(pheatmap)
library(RColorBrewer)
```

#### Loading Count Data

```r
# Read count matrix (from featureCounts)
counts <- read.table("counts_matrix.txt", header=TRUE, row.names=1)

# Remove annotation columns, keep only count columns
# Adjust column indices based on your file structure
counts <- counts[, 6:ncol(counts)]

# Read sample information
sample_info <- read.table("sample_info.txt", header=TRUE, row.names=1)

# Ensure column names match
colnames(counts) <- rownames(sample_info)
```

#### Creating DESeqDataSet

**Simple two-group design:**

```r
# Create DESeqDataSet
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ condition)

# Pre-filter low count genes (optional but recommended)
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
```

**Designs with multiple conditions and covariates:**

```r
# Example 1: Multiple conditions (e.g., control, treated1, treated2)
# Ensure condition column has appropriate factor levels
sample_info$condition <- factor(sample_info$condition, 
                                levels=c("control", "treated1", "treated2"))
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ condition)

# Example 2: With batch as covariate
sample_info$batch <- factor(sample_info$batch)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ batch + condition)

# Example 3: Multiple factors (condition and time)
sample_info$condition <- factor(sample_info$condition)
sample_info$time <- factor(sample_info$time)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ batch + condition + time + condition:time)

# Example 4: With continuous covariate (e.g., age, dose)
sample_info$age <- as.numeric(sample_info$age)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ age + condition)

# Example 5: Complex design with multiple covariates
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = sample_info,
                              design = ~ batch + age + condition + time)
```

#### Quality Control and Filtering

```r
# Estimate size factors for normalization
dds <- estimateSizeFactors(dds)

# Estimate dispersions
dds <- estimateDispersions(dds)

# Check dispersion plot
plotDispEsts(dds)

# Remove genes with extreme counts (optional)
dds <- dds[rowSums(counts(dds) >= 10) >= 3, ]  # At least 10 counts in 3 samples
```

#### Batch Effect Correction (if needed)

```r
# Detect batch effects using PCA
vsd <- vst(dds, blind=FALSE)
pcaData <- plotPCA(vsd, intgroup=c("condition", "batch"), returnData=TRUE)

# If batch effects are present, apply correction
# Example with ComBat
library(sva)
log_counts <- log2(counts(dds, normalized=TRUE) + 1)
batch <- colData(dds)$batch
condition <- colData(dds)$condition
modcombat <- model.matrix(~condition, data=colData(dds))
combat_counts <- ComBat(dat=log_counts, batch=batch, mod=modcombat)

# Update DESeqDataSet with corrected counts (convert back from log)
# Note: This is a simplified approach, not recommended; see DESeq2 documentation for alternatives
assay(dds) <- round(2^combat_counts - 1)

# Or incorporate batch in design
design(dds) <- ~ batch + condition
```

#### Differential Expression Analysis

```r
# Run DESeq2 analysis
dds <- DESeq(dds)

# Get results - Simple two-group comparison
res <- results(dds, contrast=c("condition", "treated", "control"))

# Examples with multiple conditions and covariates:

# Example 1: Multiple conditions (e.g., control, treated1, treated2)
# Design: ~ condition
# Compare treated1 vs control
res_treated1 <- results(dds, contrast=c("condition", "treated1", "control"))

# Compare treated2 vs control
res_treated2 <- results(dds, contrast=c("condition", "treated2", "control"))

# Compare treated2 vs treated1
res_treated2_vs_1 <- results(dds, contrast=c("condition", "treated2", "treated1"))

# Example 2: With batch as covariate
# Design: ~ batch + condition
# Compare treated vs control (accounting for batch)
res_batch <- results(dds, contrast=c("condition", "treated", "control"))

# Example 3: Multiple factors (condition and time) without interaction
# Design: ~ batch + time + condition
# Compare treated vs control (accounting for time and batch)
res_time <- results(dds, contrast=c("condition", "treated", "control"))

# Example 4: Testing interaction terms (condition:time)
# Design: ~ batch + condition + time + condition:time
# First, check available coefficient names
resultsNames(dds)

# Test if there is a significant interaction between condition and time
# This tests whether the effect of condition differs across time points
res_interaction_test <- results(dds, name="conditiontreated.time2")
# Or test the interaction coefficient directly
res_interaction_coef <- results(dds, name="conditiontreated.time2")

# Compare treated vs control at a specific time point
# Method 1: Using contrast list for interaction
# This compares treated vs control at time2, accounting for the interaction
res_time2 <- results(dds, 
                     contrast=list(c("condition_treated_vs_control", 
                                    "conditiontreated.time2"),
                                  c("condition_treated_vs_control", 
                                    "conditiontreated.time1")))

# Method 2: Using name parameter for main effect (averaged across time)
res_main <- results(dds, name="condition_treated_vs_control")

# Complete example: Testing interaction between condition and time
# Step 1: Create design with interaction
dds_interaction <- DESeqDataSetFromMatrix(countData = counts,
                                         colData = sample_info,
                                         design = ~ batch + condition + time + condition:time)

# Step 2: Run DESeq
dds_interaction <- DESeq(dds_interaction)

# Step 3: Check coefficient names
resultsNames(dds_interaction)
# Output might be: [1] "Intercept" "batch_batch2_vs_batch1" "condition_treated_vs_control" 
#                  [4] "time_time2_vs_time1" "conditiontreated.timetime2"

# Step 4: Test the interaction term
# This tests if the condition effect differs between time points
res_interaction <- results(dds_interaction, name="conditiontreated.timetime2")

# Step 5: Extract condition effect at each time point
# Condition effect at time1 (baseline)
res_condition_time1 <- results(dds_interaction, 
                                contrast=c("condition", "treated", "control"))

# Condition effect at time2 (includes interaction)
# This is the main effect + interaction
res_condition_time2 <- results(dds_interaction,
                               contrast=list(c("condition_treated_vs_control", 
                                              "conditiontreated.timetime2"),
                                            c(0, 0)))

#### Time-Course Analysis Specifics

Time-course experiments require special consideration in design and analysis:

**Design considerations:**
- **Time points**: Choose biologically relevant time points
- **Replicates**: Need replicates at each time point (not just overall replicates)
- **Baseline**: Include a time 0 or pre-treatment baseline
- **Balanced design**: Equal replicates across all time points when possible

**Analysis approaches:**

**1. Testing for temporal trends:**

```r
# Design with time as continuous variable
# This tests for linear trends over time
dds_time_continuous <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = sample_info,
  design = ~ batch + condition + time + condition:time
)
dds_time_continuous <- DESeq(dds_time_continuous)

# Test for interaction (does treatment effect change over time?)
res_time_interaction <- results(dds_time_continuous, 
                               name="conditiontreated.timetime2")

# Test for overall time effect
res_time_effect <- results(dds_time_continuous, name="time")
```

**2. Using splines for non-linear trends:**

```r
library(splines)

# Create spline basis for time (allows non-linear trends)
# ns() creates natural splines with specified degrees of freedom
sample_info$time_spline <- ns(sample_info$time, df=3)

# Design with splines
dds_spline <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = sample_info,
  design = ~ batch + condition + time_spline + condition:time_spline
)
dds_spline <- DESeq(dds_spline)

# Test for interaction at each spline term
resultsNames(dds_spline)
```

**3. Pairwise comparisons at each time point:**

```r
# Compare treated vs control at each time point separately
# Time point 1
res_t1 <- results(dds, 
                 contrast=list(c("condition_treated_vs_control"),
                              c(0)),
                 listValues=c(1, 0))

# Time point 2
res_t2 <- results(dds,
                 contrast=list(c("condition_treated_vs_control",
                                "conditiontreated.timetime2"),
                              c(1, 1)),
                 listValues=c(1, 0))
```

**4. Tools for time-course analysis:**

- **splineTimeR** (R package): Specifically designed for time-course RNA-seq
- **maSigPro** (R/Bioconductor): Microarray time series analysis adapted for RNA-seq
- **ImpulseDE2** (R/Bioconductor): Detects impulse-like expression patterns over time

**Example with splineTimeR:**

```r
library(splineTimeR)

# Prepare data
counts_matrix <- as.matrix(counts)
design <- model.matrix(~ condition + time + condition:time, data=sample_info)

# Run splineTimeR
spline_results <- splineTimeR(counts_matrix, design, time_col="time",
                            condition_col="condition", reference="control")

# Extract results
significant_genes <- spline_results[spline_results$padj < 0.05, ]
```

**Example with maSigPro:**

```r
library(maSigPro)

# Prepare data in maSigPro format
# Create time series design
design <- make.design.matrix(sample_info, degree=2)  # Quadratic model

# Fit model
fit <- p.vector(counts, design, Q=0.05, MT.adjust="BH")

# Get significant genes
fit$SELEC

# Get clusters of genes with similar temporal patterns
tstep <- T.fit(fit, step.method="backward", alfa=0.05)
sigs <- get.siggenes(tstep, rsq=0.6, vars="groups")
```

**Visualization for time-course data:**

```r
library(ggplot2)

# Plot expression over time for specific genes
gene_of_interest <- "ENSG00000139618"  # Example gene ID

# Get normalized counts
norm_counts <- counts(dds, normalized=TRUE)
gene_counts <- norm_counts[gene_of_interest, ]

# Create data frame for plotting
plot_data <- data.frame(
  time = sample_info$time,
  condition = sample_info$condition,
  expression = log2(gene_counts + 1)
)

# Create line plot
ggplot(plot_data, aes(x=time, y=expression, color=condition)) +
  geom_line(aes(group=interaction(condition, rep)), alpha=0.5) +
  geom_smooth(method="loess", se=TRUE) +
  labs(title=paste("Expression over time:", gene_of_interest),
       x="Time", y="Log2 Normalized Counts") +
  theme_minimal()
```

**Best practices for time-course analysis:**
1. **Plan time points carefully**: Choose time points that capture expected biological changes
2. **Include sufficient replicates**: Need replicates at each time point, not just overall
3. **Consider non-linear trends**: Biological processes often have non-linear temporal patterns
4. **Test for interactions**: Determine if treatment effects change over time
5. **Visualize temporal patterns**: Line plots and heatmaps help identify patterns
6. **Account for multiple testing**: Time-course experiments involve many comparisons

# Example 5: With continuous covariate (e.g., age)
# Design: ~ age + condition
# Compare treated vs control (accounting for age)
res_age <- results(dds, contrast=c("condition", "treated", "control"))

# Example 6: With RUV factors or surrogate variables
# Design: ~ condition + W_1 + W_2
# Compare treated vs control (accounting for unwanted variation)
res_ruv <- results(dds, contrast=c("condition", "treated", "control"))

# Example 7: Extracting specific coefficients
# Get results using coefficient name (useful for complex designs)
# First check available coefficients
resultsNames(dds)

# Then extract using name
res_coef <- results(dds, name="condition_treated_vs_control")

# Example 8: Complex design with multiple covariates
# Design: ~ batch + age + condition + time
# Compare treated vs control (accounting for all covariates)
res_complex <- results(dds, contrast=c("condition", "treated", "control"))

#### Multi-Condition Comparisons

When you have more than two conditions, you need to carefully plan your comparisons:

**Example: Three conditions (Control, Treatment A, Treatment B)**

```r
# Create sample info with three conditions
sample_info <- data.frame(
  condition = factor(c(rep("control", 3), 
                      rep("treatment_A", 3), 
                      rep("treatment_B", 3)),
                    levels = c("control", "treatment_A", "treatment_B")),
  batch = factor(rep(c("batch1", "batch2", "batch3"), 3))
)

# Create DESeqDataSet
dds <- DESeqDataSetFromMatrix(countData = counts,
                             colData = sample_info,
                             design = ~ batch + condition)

# Run DESeq
dds <- DESeq(dds)

# Method 1: Pairwise comparisons
# Compare Treatment A vs Control
res_A_vs_control <- results(dds, contrast=c("condition", "treatment_A", "control"))

# Compare Treatment B vs Control
res_B_vs_control <- results(dds, contrast=c("condition", "treatment_B", "control"))

# Compare Treatment A vs Treatment B
res_A_vs_B <- results(dds, contrast=c("condition", "treatment_A", "treatment_B"))

# Method 2: Using resultsNames to see all available comparisons
resultsNames(dds)
# Output: [1] "Intercept" "batch_batch2_vs_batch1" "batch_batch3_vs_batch1"
#         [4] "condition_treatment_A_vs_control" "condition_treatment_B_vs_control"

# Extract using coefficient names
res_A_vs_control <- results(dds, name="condition_treatment_A_vs_control")
res_B_vs_control <- results(dds, name="condition_treatment_B_vs_control")

# Method 3: ANOVA-like test (testing if any condition differs)
# This tests the overall effect of condition
dds_anova <- DESeq(dds, test="LRT", reduced=~batch)
res_anova <- results(dds_anova)

# Method 4: Custom contrasts for complex comparisons
# Example: Compare average of treatments vs control
res_treatments_vs_control <- results(dds,
                                     contrast=list(
                                       c("condition_treatment_A_vs_control",
                                         "condition_treatment_B_vs_control"),
                                       c(0.5, 0.5)  # Average of the two treatments
                                     ))
```

**Best practices for multi-condition comparisons:**
1. **Define all comparisons a priori**: Decide which comparisons are biologically meaningful before analysis
2. **Account for multiple testing**: When performing multiple pairwise comparisons, be aware that you're increasing the chance of false positives
3. **Use appropriate controls**: Ensure your control group is appropriate for all treatment comparisons
4. **Consider interaction effects**: If treatments might interact, include interaction terms in the design
5. **Visualize all conditions**: Use PCA plots and heatmaps to visualize relationships between all conditions

**Visualization for multi-condition experiments:**

```r
# Heatmap with all conditions
library(pheatmap)
library(viridis)

# Get normalized counts
norm_counts <- counts(dds, normalized=TRUE)

# Select top variable genes
top_genes <- head(order(rowVars(norm_counts), decreasing=TRUE), 50)

# Create annotation for conditions
annotation_col <- data.frame(Condition = sample_info$condition)
rownames(annotation_col) <- colnames(norm_counts)

# Create heatmap
pheatmap(log2(norm_counts[top_genes, ] + 1),
         annotation_col = annotation_col,
         color = viridis(100),
         cluster_rows = TRUE,
         cluster_cols = TRUE,
         show_rownames = FALSE,
         main = "Top 50 Variable Genes Across Conditions")
```

**Sankey diagrams for multi-condition experiments:**

```r
library(networkD3)

# Create a data frame of significant genes in each comparison
sig_A <- rownames(res_A_vs_control)[!is.na(res_A_vs_control$padj) & 
                                     res_A_vs_control$padj < 0.05]
sig_B <- rownames(res_B_vs_control)[!is.na(res_B_vs_control$padj) & 
                                   res_B_vs_control$padj < 0.05]

# Find overlaps
both_sig <- intersect(sig_A, sig_B)
only_A <- setdiff(sig_A, sig_B)
only_B <- setdiff(sig_B, sig_A)

# Create nodes and links for Sankey diagram
nodes <- data.frame(name = c("Control", "Treatment A", "Treatment B",
                            "DE in A only", "DE in B only", "DE in both"))
links <- data.frame(
  source = c(0, 1, 2, 0, 1),
  target = c(3, 3, 4, 5, 5),
  value = c(length(only_A), length(only_A), length(only_B), 
           length(both_sig), length(both_sig))
)

# Create Sankey diagram
sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             fontSize = 12, nodeWidth = 30)
```

# Shrink log2 fold changes (recommended for visualization)
# For simple contrast
resLFC <- lfcShrink(dds, coef="condition_treated_vs_control", type="apeglm")

# For custom contrast, use contrast parameter
resLFC_contrast <- lfcShrink(dds, contrast=c("condition", "treated", "control"), type="apeglm")

# Order by adjusted p-value
resOrdered <- res[order(res$padj),]

# Summary
summary(res)
```

#### Results Interpretation

Key columns in results:
- **baseMean**: Average normalized count across all samples
- **log2FoldChange**: Log2 fold change between conditions
- **lfcSE**: Standard error of log2 fold change
- **stat**: Wald statistic
- **pvalue**: Raw p-value
- **padj**: Adjusted p-value (FDR, Benjamini-Hochberg)

**Filtering significant genes:**
```r
# Genes with padj < 0.05 and |log2FC| > 1
sig_genes <- res[which(!is.na(res$padj) & res$padj < 0.05 & abs(res$log2FoldChange) > 1), ]
```

#### Visualization of Differential Expression Results

Visualization is crucial for understanding and communicating your results. Here are common visualization approaches:

**Publication-ready figure guidelines:**
- **Resolution**: Use 300 DPI (dots per inch) or higher for publication
- **Formats**: 
  - **Vector formats** (PDF, SVG) for line plots, scatter plots - scale without quality loss
  - **Raster formats** (PNG, TIFF) for heatmaps - use high resolution (300+ DPI)
- **Color palettes**: Use colorblind-friendly palettes (viridis, ColorBrewer)
- **Font sizes**: Ensure text is readable when figure is resized (typically 10-12pt minimum)
- **Figure dimensions**: Common sizes: single column (3.5 inches), double column (7 inches)
- **File organization**: Save both R code and final figures separately

##### MA Plots

MA plots show log2 fold change vs. mean expression:

```r
# Basic MA plot
plotMA(res, ylim=c(-2,2))

# Enhanced MA plot with ggplot2
res_df <- as.data.frame(res)
res_df$significant <- ifelse(res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1, 
                             "Yes", "No")

ggplot(res_df, aes(x=baseMean, y=log2FoldChange, color=significant)) +
  geom_point(alpha=0.6) +
  scale_x_log10() +
  scale_color_manual(values=c("gray", "red")) +
  geom_hline(yintercept=c(-1, 1), linetype="dashed") +
  labs(x="Mean Expression", y="Log2 Fold Change", title="MA Plot")
```

##### Volcano Plots

Volcano plots show statistical significance vs. fold change:

```r
res_df$neg_log10_padj <- -log10(res_df$padj)

ggplot(res_df, aes(x=log2FoldChange, y=neg_log10_padj, color=significant)) +
  geom_point(alpha=0.6) +
  scale_color_manual(values=c("gray", "red")) +
  geom_vline(xintercept=c(-1, 1), linetype="dashed") +
  geom_hline(yintercept=-log10(0.05), linetype="dashed") +
  labs(x="Log2 Fold Change", y="-Log10 Adjusted P-value", title="Volcano Plot") +
  theme_minimal()

# Save publication-ready figure
ggsave("volcano_plot.pdf", width=7, height=6, dpi=300)
ggsave("volcano_plot.png", width=7, height=6, dpi=300)  # Also save PNG version
```

**Creating multi-panel figures:**

```r
library(gridExtra)
library(cowplot)  # Alternative package for arranging plots

# Create multiple plots
p1 <- ggplot(ma_data, aes(x=baseMean, y=log2FoldChange, color=significant)) +
  geom_point(alpha=0.6) +
  scale_color_manual(values=c("gray", "red")) +
  theme_minimal()

p2 <- ggplot(volcano_data, aes(x=log2FC, y=-log10(padj), color=significant)) +
  geom_point(alpha=0.6) +
  scale_color_manual(values=c("gray", "red")) +
  theme_minimal()

# Arrange plots side by side
combined_plot <- plot_grid(p1, p2, labels=c("A", "B"), ncol=2)

# Save combined figure
ggsave("combined_plots.pdf", combined_plot, width=14, height=6, dpi=300)
```

**Color palette recommendations:**

```r
# Colorblind-friendly palettes
library(viridis)
library(RColorBrewer)

# Viridis palettes (excellent for continuous data)
scale_color_viridis_c()  # Continuous
scale_color_viridis_d()   # Discrete

# ColorBrewer palettes (good for categorical data)
scale_color_brewer(palette="Set2")  # Qualitative
scale_color_brewer(palette="RdYlBu")  # Diverging

# Custom colorblind-friendly palette
cb_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7")
```

**Export settings for different journals:**

```r
# Nature/Science style (single column, high resolution)
ggsave("figure.pdf", width=3.5, height=3.5, units="in", dpi=300)

# PLoS style (wider figures)
ggsave("figure.pdf", width=7, height=5, units="in", dpi=300)

# General publication (adjust as needed)
ggsave("figure.pdf", width=6, height=4.5, units="in", dpi=300)
```

##### Heatmaps (for Multi-Condition Experiments)

Heatmaps are excellent for visualizing expression patterns across multiple conditions:

```r
library(ComplexHeatmap)
library(circlize)

# Select top variable genes
top_genes <- head(order(res$padj), 50)

# Get normalized counts
vsd <- vst(dds, blind=FALSE)
mat <- assay(vsd)[top_genes, ]

# Z-score normalization for visualization
mat_scaled <- t(scale(t(mat)))

# Create heatmap
Heatmap(mat_scaled,
        name = "Z-score",
        column_title = "Samples",
        row_title = "Genes",
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        show_row_names = FALSE,
        col = colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
        top_annotation = HeatmapAnnotation(
          Condition = colData(dds)$condition,
          Batch = colData(dds)$batch,
          col = list(Condition = c("control" = "blue", "treated" = "red"),
                     Batch = c("batch1" = "gray", "batch2" = "black"))
        ))
```

**Alternative with pheatmap:**

```r
library(pheatmap)

# Prepare annotation
ann_col <- data.frame(
  Condition = colData(dds)$condition,
  Batch = colData(dds)$batch
)
rownames(ann_col) <- colnames(mat_scaled)

# Create heatmap
pheatmap(mat_scaled,
         annotation_col = ann_col,
         cluster_rows = TRUE,
         cluster_cols = TRUE,
         show_rownames = FALSE,
         color = colorRampPalette(c("blue", "white", "red"))(100))
```

##### Sankey Diagrams (for Multi-Condition Experiments)

Sankey diagrams visualize gene flow and relationships across conditions:

```r
library(networkD3)
library(dplyr)

# Example: Compare DE genes across multiple conditions
# Get DE genes for each comparison
de_cond1 <- rownames(res_cond1)[res_cond1$padj < 0.05]
de_cond2 <- rownames(res_cond2)[res_cond2$padj < 0.05]
de_cond3 <- rownames(res_cond3)[res_cond3$padj < 0.05]

# Create links data
links <- data.frame(
  source = c(rep("Condition1", length(de_cond1)),
             rep("Condition2", length(de_cond2)),
             rep("Condition3", length(de_cond3))),
  target = c(de_cond1, de_cond2, de_cond3),
  value = 1
)

# Create nodes
nodes <- data.frame(
  name = c("Condition1", "Condition2", "Condition3", 
           unique(c(de_cond1, de_cond2, de_cond3)))
)

# Create Sankey diagram
sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              units = "genes", fontSize = 12, nodeWidth = 30)
```

**Alternative with ggplot2 and ggalluvial:**

```r
library(ggalluvial)

# Prepare data for alluvial plot
de_data <- data.frame(
  Condition = rep(c("Control", "Treated1", "Treated2"), each=100),
  Gene = c(sample(de_cond1, 100), sample(de_cond2, 100), sample(de_cond3, 100)),
  Direction = sample(c("Up", "Down"), 300, replace=TRUE)
)

ggplot(de_data, aes(x = Condition, stratum = Gene, alluvium = Gene,
                     fill = Direction)) +
  geom_flow() +
  geom_stratum() +
  theme_minimal()
```

### Brief Mentions of edgeR and limma/voom

#### edgeR

edgeR is similar to DESeq2 but uses a different normalization method:

```r
library(edgeR)

# Create DGEList object
dge <- DGEList(counts=counts, group=sample_info$condition)

# Filter and normalize
dge <- calcNormFactors(dge)
dge <- estimateDisp(dge)

# Fit model and test
fit <- glmFit(dge, design)
lrt <- glmLRT(fit, coef=2)
topTags(lrt)
```

**Best for:** Similar use cases to DESeq2, sometimes faster

#### limma/voom

limma with voom transformation is powerful for complex designs:

```r
library(limma)

# Voom transformation
v <- voom(counts, design, plot=TRUE)

# Fit linear model
fit <- lmFit(v, design)
fit <- eBayes(fit)

# Get results
topTable(fit, coef=2)
```

**Best for:** Large sample sizes, complex experimental designs, microarray-like analysis

---

## Section 7: Overrepresentation Analysis (ORA)

Overrepresentation Analysis (ORA) identifies which biological pathways, processes, or functions are overrepresented in a list of differentially expressed genes. It's a simple but powerful method for interpreting the biological meaning of your results.

### Introduction to ORA

ORA tests whether genes in your gene list (e.g., significantly upregulated genes) are enriched for specific biological annotations compared to a background set of genes. It uses statistical tests (typically hypergeometric or Fisher's exact test) to determine if certain gene sets appear more frequently than expected by chance.

### Background Selection (Critical Importance)

The choice of background gene set is **critical** and directly affects the results and interpretation of ORA.

#### What is Background and Why It Matters

The background gene set represents the "universe" of genes from which your gene list was drawn. It defines what genes are considered "available" for enrichment, which directly impacts:

- **Statistical significance**: Different backgrounds yield different p-values
- **Biological interpretation**: Results may change dramatically
- **False positive/negative rates**: Wrong background can create or hide enrichments

#### Common Background Choices

**All genes in the genome:** (not recommended)
- Includes all annotated genes
- May include genes not expressed in your experiment
- Can dilute enrichment signals
- **Use when**: You want the broadest possible comparison

**All genes detected/expressed in the experiment:**
- Only genes with some expression in your samples
- More appropriate for RNA-seq experiments
- Reduces false positives from non-expressed genes
- **Use when**: You want experiment-specific context (RECOMMENDED for most RNA-seq)

**All genes passing quality filters:**
- Genes that passed your filtering criteria (e.g., minimum counts)
- Most conservative and appropriate
- Matches your actual analysis
- **Use when**: You want to match your DE analysis exactly (OFTEN BEST CHOICE)

**All genes in a specific pathway database:**
- Only genes annotated in the database you're testing
- Very conservative
- May miss relevant pathways
- **Use when**: Testing specific curated pathways

#### Impact of Background Selection on Results

**Statistical significance (p-values):**
- Smaller background → More significant results (but may be inflated)
- Larger background → Less significant results

**False positive/negative rates:**
- Too permissive background → More false positives
- Too restrictive background → More false negatives

**Biological interpretation:**
- Wrong background can make pathways appear enriched when they're not
- Can hide true enrichments if background is too broad

#### Best Practices for Background Selection

1. **Match background to experimental design:**
   - Use genes that could realistically be detected in your experiment
   - Consider your library type (polyA-selected vs. total RNA)

2. **Use experiment-specific background (detected genes):**
   - Most appropriate for RNA-seq
   - Reduces false positives from non-expressed genes
   - Better reflects your actual experimental context

3. **Avoid overly restrictive or permissive backgrounds:**
   - Too restrictive: May miss relevant pathways
   - Too permissive: May create false enrichments

4. **Document background choice:**
   - Always report which background you used
   - Justify your choice
   - Consider sensitivity analysis with different backgrounds

#### Common Pitfalls and Mistakes

- **Using genome-wide background for tissue-specific experiments**: Should use tissue-expressed genes
- **Including non-expressed genes**: Creates false enrichments
- **Not matching background to filtering criteria**: Background should match your DE analysis
- **Using different backgrounds for up- and down-regulated genes**: Should be consistent
- **Not documenting background choice**: Makes results irreproducible

### Gene List Preparation

Prepare your gene list from differential expression results:

```r
# Get significantly upregulated genes
up_genes <- rownames(res)[!is.na(res$padj) & res$padj < 0.05 & res$log2FoldChange > 1]

# Get significantly downregulated genes
down_genes <- rownames(res)[!is.na(res$padj) & res$padj < 0.05 & res$log2FoldChange < -1]

# Get all significant genes
all_sig_genes <- rownames(res)[!is.na(res$padj) & res$padj < 0.05]

# Convert to appropriate format (e.g., Entrez IDs, gene symbols)
# This depends on your annotation and the tool you're using
```

### Main Sources of Gene Sets

Multiple databases provide gene sets for enrichment analysis:

#### GO (Gene Ontology) Terms

The Gene Ontology provides structured vocabularies for gene function:

**Biological Process (BP):** High-level biological objectives (e.g., "cell cycle", "immune response")

**Molecular Function (MF):** Molecular activities of gene products (e.g., "kinase activity", "DNA binding")

**Cellular Component (CC):** Locations where gene products act (e.g., "nucleus", "mitochondrion")

**Hierarchical structure and relationships:**
- GO terms are organized in a directed acyclic graph (DAG)
- Terms have parent-child relationships
- More specific terms are children of more general terms

**GO enrichment databases and resources:**
- GO database: http://geneontology.org/
- org.Hs.eg.db (Bioconductor): Human GO annotations
- org.Mm.eg.db: Mouse GO annotations
- Other species-specific packages available

#### KEGG (Kyoto Encyclopedia of Genes and Genomes) Pathways

KEGG provides curated pathway maps:

**Metabolic pathways:** Biochemical reactions and pathways

**Signaling pathways:** Signal transduction cascades

**Disease pathways:** Disease-related pathways

**Organism-specific pathways:** Pathways annotated for specific organisms

**Resources:**
- KEGG database: https://www.genome.jp/kegg/
- KEGGREST (Bioconductor): R interface to KEGG
- KEGG.db (Bioconductor): Local KEGG pathway annotations

#### REACTOME

REACTOME is a curated pathway database:

**Curated pathway database:** Expert-curated, peer-reviewed pathways

**Human pathways with orthologs:** Primarily human, with orthologs in other species

**Hierarchical pathway structure:** Pathways organized hierarchically

**Resources:**
- REACTOME database: https://reactome.org/
- reactome.db (Bioconductor): R interface

#### WikiPathways

WikiPathways is a community-curated pathway resource:

**Community-curated pathways:** Pathways created and maintained by the research community

**Multiple species coverage:** Pathways for various organisms

**Pathway visualization:** Interactive pathway diagrams

**Resources:**
- WikiPathways: https://www.wikipathways.org/
- rWikiPathways (Bioconductor): R interface

#### MSigDB (Molecular Signatures Database)

MSigDB provides comprehensive gene set collections:

**Hallmark gene sets:** 50 well-defined gene sets representing specific biological states

**Curated gene sets:** Gene sets from various sources (pathways, literature, etc.)

**Motif gene sets:** Gene sets based on transcription factor binding motifs

**Computational gene sets:** Gene sets identified through computational analysis

**GO gene sets:** GO terms organized as gene sets

**Oncogenic signatures:** Cancer-related gene signatures

**Immunologic signatures:** Immune system-related gene sets

**Resources:**
- MSigDB: https://www.gsea-msigdb.org/gsea/msigdb/
- msigdbr (Bioconductor): R package for MSigDB gene sets for 20 species

#### Enrichr

Enrichr is a web-based enrichment analysis platform:

**Web-based platform:** Easy-to-use web interface

**Multiple gene set libraries:** Integrates many gene set databases

**Interactive visualization:** Rich visualizations and interactive results

**API access:** Programmatic access available

**Resources:**
- Enrichr: https://maayanlab.cloud/Enrichr/
- enrichR (CRAN): R package for Enrichr API

#### Comparison of Gene Set Sources

| Source | Coverage | Curation | Update Frequency | Species | Best For |
|--------|----------|----------|------------------|---------|----------|
| **GO** | Comprehensive | High | Regular | Many | General functional annotation |
| **KEGG** | Focused | High | Regular | Many | Metabolic and signaling pathways |
| **REACTOME** | Comprehensive | Very High | Regular | Primarily human | Detailed pathway analysis |
| **WikiPathways** | Growing | Community | Continuous | Many | Community knowledge, visualization |
| **MSigDB** | Very Comprehensive | Variable | Regular | Primarily human/mouse | Comprehensive analysis, cancer research |
| **Enrichr** | Very Comprehensive | Variable | Regular | Many | Quick analysis, multiple databases |

**Use cases and recommendations:**
- **General functional analysis**: GO terms
- **Pathway analysis**: KEGG, REACTOME, WikiPathways
- **Comprehensive analysis**: MSigDB
- **Quick exploration**: Enrichr
- **Disease-specific**: MSigDB oncogenic/immunologic signatures
- **Metabolic focus**: KEGG

### Tools and Methods

Common tools for ORA:

```r
# Using clusterProfiler (Bioconductor)
library(clusterProfiler)
library(org.Hs.eg.db)

# Convert gene IDs (if needed)
gene_ids <- bitr(up_genes, fromType="SYMBOL", toType="ENTREZID", 
                 OrgDb=org.Hs.eg.db)

# GO enrichment
go_enrich <- enrichGO(gene = gene_ids$ENTREZID,
                      OrgDb = org.Hs.eg.db,
                      ont = "BP",
                      pAdjustMethod = "BH",
                      pvalueCutoff = 0.05,
                      qvalueCutoff = 0.2,
                      readable = TRUE)

# KEGG enrichment
kegg_enrich <- enrichKEGG(gene = gene_ids$ENTREZID,
                          organism = "hsa",
                          pvalueCutoff = 0.05)

# REACTOME enrichment
library(reactome.db)
reactome_enrich <- enrichPathway(gene = gene_ids$ENTREZID,
                                  organism = "human",
                                  pvalueCutoff = 0.05)
```

### Interpretation of Results

Key metrics to interpret:
- **p-value / adjusted p-value**: Statistical significance
- **Gene ratio**: Proportion of genes in your list that are in the gene set
- **Background ratio**: Proportion of background genes in the gene set
- **Gene list**: Which of your genes are in the enriched set

### Examples with Different Background Selections

```r
# Example 1: Genome-wide background
go_genome <- enrichGO(gene = gene_ids$ENTREZID,
                      universe = NULL,  # All genes in database
                      OrgDb = org.Hs.eg.db,
                      ont = "BP")

# Example 2: Experiment-specific background (detected genes)
detected_genes <- rownames(counts)[rowSums(counts) > 0]
detected_ids <- bitr(detected_genes, fromType="SYMBOL", toType="ENTREZID",
                     OrgDb=org.Hs.eg.db)

go_detected <- enrichGO(gene = gene_ids$ENTREZID,
                        universe = detected_ids$ENTREZID,  # Only detected genes
                        OrgDb = org.Hs.eg.db,
                        ont = "BP")

# Example 3: Filtered genes background (matches DE analysis)
filtered_genes <- rownames(dds)  # Genes that passed filtering
filtered_ids <- bitr(filtered_genes, fromType="SYMBOL", toType="ENTREZID",
                     OrgDb=org.Hs.eg.db)

go_filtered <- enrichGO(gene = gene_ids$ENTREZID,
                        universe = filtered_ids$ENTREZID,  # Matches DE analysis
                        OrgDb = org.Hs.eg.db,
                        ont = "BP")

# Compare results
head(go_genome@result)
head(go_detected@result)
head(go_filtered@result)
```

---

## Section 8: Gene Set Enrichment Analysis (GSEA)

Gene Set Enrichment Analysis (GSEA) is a powerful method that considers all genes in your dataset, not just those that pass a significance threshold. It's particularly useful when you have many genes with small but coordinated changes.

### Introduction to GSEA and fgsea

GSEA tests whether predefined gene sets show statistically significant, concordant differences between two biological states. Unlike ORA, GSEA:

- Uses all genes, ranked by their association with the phenotype
- Doesn't require arbitrary significance thresholds
- Can detect subtle but coordinated changes
- Is more sensitive to pathway-level effects

**fgsea** (Fast Gene Set Enrichment Analysis) is an R implementation that's faster than the original GSEA software and integrates well with R workflows.

### Loading fgsea R Package

```r
# Install if needed
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("fgsea")

# Load library
library(fgsea)
library(data.table)
```

### Preparing Ranked Gene Lists

GSEA requires genes ranked by their association with the phenotype (e.g., log2 fold change, t-statistic):

```r
# Get gene statistics from DESeq2 results
res_stat <- res$stat  # or use log2FoldChange
names(res_stat) <- rownames(res)

# Sort by statistic (decreasing)
ranks <- sort(res_stat, decreasing=TRUE)

# Alternatively, rank by -log10(p-value) * sign(log2FC)
res$ranking_metric <- -log10(res$padj) * sign(res$log2FoldChange)
ranks <- sort(setNames(res$ranking_metric, rownames(res)), decreasing=TRUE)
```

### Gene Set Databases

#### MSigDB (Molecular Signatures Database)

MSigDB is the primary source for GSEA gene sets:

```r
library(msigdbr)

# Get gene sets (example: Hallmark gene sets)
hallmark_sets <- msigdbr(species = "Homo sapiens", category = "H")
hallmark_list <- split(x = hallmark_sets$gene_symbol,
                       f = hallmark_sets$gs_name)

# Other categories available:
# - "C2": Curated gene sets
# - "C3": Motif gene sets
# - "C5": GO gene sets
# - "C6": Oncogenic signatures
# - "C7": Immunologic signatures
```

#### Enrichr

Enrichr gene sets can also be used, though MSigDB is more commonly used for GSEA:

```r
# Enrichr gene sets are typically accessed through the web interface
# or via the enrichR package for specific libraries
library(enrichR)

# List available databases
dbs <- listEnrichrDbs()
```

### Running fgsea Analysis

```r
# Run GSEA
fgsea_res <- fgsea(pathways = hallmark_list,
                   stats = ranks,
                   minSize = 15,        # Minimum gene set size
                   maxSize = 500,       # Maximum gene set size
                   nperm = 10000)       # Number of permutations

# Sort by normalized enrichment score (NES)
fgsea_res <- fgsea_res[order(NES, decreasing=TRUE),]

# Filter significant results
sig_pathways <- fgsea_res[padj < 0.05 & abs(NES) > 1, ]
```

**Key parameters:**
- `minSize`: Minimum number of genes in a gene set (default: 15)
- `maxSize`: Maximum number of genes in a gene set (default: 500)
- `nperm`: Number of permutations for p-value calculation (more = more accurate but slower)

### Interpreting Results

Key columns in fgsea results:
- **pathway**: Name of the gene set
- **pval**: Nominal p-value
- **padj**: Adjusted p-value (FDR)
- **ES**: Enrichment score
- **NES**: Normalized enrichment score (normalized across gene set sizes)
- **size**: Number of genes in the gene set
- **leadingEdge**: Genes that contribute most to the enrichment

**Interpretation:**
- **Positive NES**: Gene set is enriched at the top of the ranked list (upregulated)
- **Negative NES**: Gene set is enriched at the bottom (downregulated)
- **|NES| > 1**: Generally considered significant
- **padj < 0.05**: Statistically significant after multiple testing correction

### Visualization

#### Enrichment Plots

```r
# Plot top enriched pathway
plotEnrichment(hallmark_list[["HALLMARK_INTERFERON_ALPHA_RESPONSE"]],
               ranks) + 
  labs(title="HALLMARK_INTERFERON_ALPHA_RESPONSE")

# Create a table plot of top results
library(ggplot2)
top_pathways <- head(fgsea_res[order(padj), ], 10)

ggplot(top_pathways, aes(reorder(pathway, NES), NES)) +
  geom_col(aes(fill = padj < 0.05)) +
  coord_flip() +
  labs(x="Pathway", y="Normalized Enrichment Score",
       title="GSEA Results") +
  theme_minimal()
```

#### Pathway Networks

```r
# Visualize leading edge genes
library(ComplexHeatmap)

# Get leading edge genes for top pathways
top_pathway <- fgsea_res[1, pathway]
leading_genes <- fgsea_res[pathway == top_pathway, leadingEdge][[1]]

# Create heatmap of leading edge genes
leading_ranks <- ranks[names(ranks) %in% leading_genes]
mat <- matrix(leading_ranks, nrow=length(leading_ranks), ncol=1)
rownames(mat) <- names(leading_ranks)

Heatmap(mat, name = "Rank", cluster_rows = FALSE)
```

### R Code Examples

**Complete GSEA workflow:**

```r
library(fgsea)
library(msigdbr)
library(ggplot2)

# 1. Prepare ranked gene list
ranks <- sort(res$stat, decreasing=TRUE)
names(ranks) <- rownames(res)

# 2. Get gene sets
hallmark_sets <- msigdbr(species = "Homo sapiens", category = "H")
hallmark_list <- split(x = hallmark_sets$gene_symbol,
                       f = hallmark_sets$gs_name)

# 3. Run GSEA
fgsea_res <- fgsea(pathways = hallmark_list,
                   stats = ranks,
                   minSize = 15,
                   maxSize = 500,
                   nperm = 10000)

# 4. Filter and sort
sig_pathways <- fgsea_res[padj < 0.05 & abs(NES) > 1, ]
sig_pathways <- sig_pathways[order(NES, decreasing=TRUE), ]

# 5. Visualize
ggplot(sig_pathways[1:20, ], aes(reorder(pathway, NES), NES)) +
  geom_col(aes(fill = NES > 0)) +
  coord_flip() +
  labs(x="Pathway", y="Normalized Enrichment Score") +
  scale_fill_manual(values=c("blue", "red"), 
                    labels=c("Down", "Up")) +
  theme_minimal()
```

---

## Section 9: Reproducibility and Data Sharing

Ensuring reproducibility is essential for scientific research. Here are best practices for making your RNA-seq analysis reproducible:

### Recording Software Versions

Always document the versions of all software and packages used:

```r
# In R, record package versions
sessionInfo()

# Or create a more detailed report
writeLines(capture.output(sessionInfo()), "R_session_info.txt")
```

**For command-line tools:**
```bash
# Record versions
echo "STAR version: $(STAR --version)" >> software_versions.txt
echo "featureCounts version: $(featureCounts -v)" >> software_versions.txt
echo "FastQC version: $(fastqc --version)" >> software_versions.txt
```

### Using Containers for Reproducibility

Containers (Docker, Singularity) ensure consistent software environments:

**Docker example:**
```dockerfile
# Dockerfile for RNA-seq analysis
FROM continuumio/miniconda3
RUN conda install -c bioconda star featurecounts fastqc
RUN conda install -c conda-forge r-base r-deseq2
```

**Singularity example:**
```bash
# Build from Docker image
singularity build rnaseq_analysis.sif docker://biocontainers/star:latest
```

### Version Control

Use Git to track your analysis code:

```bash
# Initialize repository
git init
git add *.R *.sh *.yaml
git commit -m "Initial RNA-seq analysis code"
```

**Best practices:**
- Track code, not data (use `.gitignore` for large files)
- Write clear commit messages
- Use branches for experimental analyses
- Tag releases/versions

### Creating Reproducible Reports

**R Markdown for integrated analysis and reporting:**

```r
# Example R Markdown structure
---
title: "RNA-seq Analysis Report"
author: "Your Name"
date: "`r Sys.Date()`"
output: 
  html_document:
    toc: true
    toc_float: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)
library(DESeq2)
library(ggplot2)
```

```{r load-data}
counts <- read.table("counts.txt", header=TRUE, row.names=1)
```

# Results

## Differential Expression

```{r de-analysis}
dds <- DESeqDataSetFromMatrix(countData = counts, ...)
dds <- DESeq(dds)
res <- results(dds)
```
```

**Jupyter notebooks** (Python-based analysis):
- Good for interactive exploration
- Supports multiple languages (R, Python, bash)
- Easy to share and collaborate

### Data Sharing

**Where to share data:**
- **GEO (Gene Expression Omnibus)**: https://www.ncbi.nlm.nih.gov/geo/
  - For processed data (count matrices, normalized data)
  - Requires metadata and sample information
- **SRA (Sequence Read Archive)**: https://www.ncbi.nlm.nih.gov/sra
  - For raw sequencing data (FASTQ files)
  - Linked to GEO submissions
- **Zenodo**: https://zenodo.org/
  - For code, intermediate files, and supplementary data
  - Provides DOIs for citations

**What to share:**
- Raw sequencing data (FASTQ files) - via SRA
- Processed count matrices - via GEO
- Analysis code and scripts - via GitHub/Zenodo
- Metadata and sample information - via GEO
- Key intermediate files (if space allows)

**Metadata requirements:**
- Sample information (conditions, replicates, etc.)
- Experimental design
- Processing parameters
- Software versions
- Quality control metrics

### Creating Analysis Scripts

Organize your analysis into modular scripts:

```bash
# Example workflow script structure
# 01_qc.sh - Quality control
# 02_trim.sh - Adapter trimming
# 03_align.sh - Read alignment
# 04_quantify.sh - Expression quantification
# 05_de_analysis.R - Differential expression
# 06_enrichment.R - Functional enrichment
```

**Best practices:**
- Use relative paths (not absolute paths)
- Include comments explaining each step
- Make scripts executable and well-documented
- Test scripts on a subset of data first

### Documentation

Document your analysis thoroughly:

1. **README files**: Explain how to run the analysis
2. **Comments in code**: Explain why, not just what
3. **Analysis logs**: Record parameters and decisions
4. **Troubleshooting notes**: Document issues and solutions

---

## Section 10: Workflow Integration

Putting all the steps together into a cohesive analysis pipeline is crucial for reproducible and reliable results.

### Putting It All Together

A complete bulk RNA-seq analysis workflow:

1. **Quality Control**: FastQC on raw reads
2. **Trimming** (if needed): fastp or similar
3. **Alignment**: STAR with genome index
4. **Post-alignment QC**: QoRTs or similar
5. **Quantification**: featureCounts
6. **Contamination Check**: Review featureCounts summary, IGV visualization
7. **Differential Expression**: DESeq2 with batch correction if needed
8. **Functional Enrichment**: ORA and/or GSEA

### Best Practices

1. **Document everything**: Keep detailed notes on parameters, versions, and decisions
2. **Version control**: Track software versions and analysis scripts
3. **Reproducibility**: Use scripts, not manual steps
4. **Quality at each step**: Don't proceed if QC fails
5. **Appropriate controls**: Include positive and negative controls
6. **Statistical rigor**: Use appropriate multiple testing correction
7. **Biological validation**: Verify key findings with independent methods

### Common Pitfalls

1. **Skipping QC steps**: Always check quality at each stage
2. **Ignoring batch effects**: Can create false results
3. **Wrong background in ORA**: Dramatically affects results
4. **Not checking for contamination**: Can lead to misinterpretation
5. **Over-interpreting p-values**: Consider effect sizes and biological relevance
6. **Not validating findings**: Important results should be confirmed

### Troubleshooting Tips

**Low alignment rates:**
- Check read quality
- Verify genome/annotation versions match
- Check for contamination
- Consider different aligner or parameters

**High contamination:**
- Review sample preparation
- Use appropriate cleanup tools
- Consider excluding severely contaminated samples

**No significant DE genes:**
- Check if effect sizes are biologically meaningful
- Verify experimental design and sample sizes
- Check for batch effects masking signal
- Consider less stringent thresholds (with caution)

**Unexpected enrichment results:**
- Verify background gene set
- Check gene ID conversion
- Review gene set definitions
- Consider alternative databases

---

## Conclusion

This tutorial has covered the complete workflow for bulk RNA-seq data analysis, from raw reads to biological interpretation. The key steps include:

1. **Quality control** to ensure data integrity
2. **Alignment** to map reads to the genome
3. **Quantification** to count gene expression
4. **Differential expression analysis** to find significant changes
5. **Functional enrichment** to understand biological meaning

### Summary of Workflow

- Raw read QC (FastQC) → Adapter trimming (if needed) → Alignment (STAR) → Post-alignment QC (QoRTs) → Quantification (featureCounts) → Contamination detection → Differential expression (DESeq2) → Functional enrichment (ORA/GSEA)

### Next Steps

- Explore single-cell RNA-seq for cellular heterogeneity
- Learn spatial transcriptomics for tissue context
- Dive deeper into alternative splicing analysis
- Investigate time-course and multi-condition experimental designs
- Learn about network analysis and pathway modeling

### Additional Resources

- **Bioconductor**: https://www.bioconductor.org/ - R packages for genomic analysis
- **Galaxy**: https://usegalaxy.org/ - Web-based analysis platform
- **nf-core**: https://nf-co.re/ - Nextflow pipelines for RNA-seq
- **RNA-seq blog**: https://www.rna-seqblog.com/ - Latest RNA-seq news and methods
- **Key papers**:
  - Dobin et al. (2013) STAR: ultrafast universal RNA-seq aligner
  - Love et al. (2014) Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2
  - Subramanian et al. (2005) Gene set enrichment analysis

---

*This tutorial provides a comprehensive foundation for bulk RNA-seq analysis. Remember that each experiment is unique, and you may need to adapt these methods to your specific research questions and data characteristics.*

