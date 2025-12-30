---
layout: post
title: "Best Practices for Building Subworkflows from Multiple Modules"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, subworkflows, modules, bioinformatics, workflows, best-practices]
author: Haibo Liu, PhD
toc: true
---


This document outlines best practices for creating Nextflow subworkflows that combine multiple modules into reusable, composable workflow units.


## Subworkflow Structure

### 1. Standard Subworkflow Definition

Every subworkflow should follow this basic structure:

```groovy
//
// Brief description of what the subworkflow does
//

include { MODULE_1 } from '../../../modules/nf-core/module1/main'
include { MODULE_2 } from '../../../modules/nf-core/module2/main'
include { SUBWORKFLOW_1 } from '../other_subworkflow'

workflow SUBWORKFLOW_NAME {
    take:
    // Input channel definitions

    main:
    // Workflow logic

    emit:
    // Output channel definitions
}
```

### 2. File Organization

Organize subworkflows in a clear directory structure:

```text
subworkflows/
├── nf-core/              # nf-core standard subworkflows
│   ├── subworkflow_name/
│   │   ├── main.nf       # Main subworkflow definition
│   │   ├── meta.yml      # Metadata and documentation
│   │   └── tests/         # Test files
│   │       ├── main.nf.test
│   │       └── nextflow.config
└── local/                # Pipeline-specific subworkflows
    └── subworkflow_name/
        └── main.nf
```

---

## Module Inclusion and Aliasing

### 1. Include Statements

Place all `include` statements at the top of the file:

```groovy
//
// Include modules
//
include { FASTQC as FASTQC_RAW  } from '../../../modules/nf-core/fastqc/main'
include { FASTQC as FASTQC_TRIM } from '../../../modules/nf-core/fastqc/main'
include { UMITOOLS_EXTRACT      } from '../../../modules/nf-core/umitools/extract/main'
include { FASTP                 } from '../../../modules/nf-core/fastp/main'

//
// Include other subworkflows
//
include { FASTQ_SUBSAMPLE_FQ_SALMON } from '../fastq_subsample_fq_salmon'
```

### 2. Module Aliasing

Use aliasing when the same module is used multiple times:

```groovy
// Same module, different aliases for different contexts
include { FASTQC as FASTQC_RAW  } from '../../../modules/nf-core/fastqc/main'
include { FASTQC as FASTQC_TRIM } from '../../../modules/nf-core/fastqc/main'

// Aliased subworkflow instances
include { BAM_DEDUP_STATS_SAMTOOLS_UMICOLLAPSE as BAM_DEDUP_STATS_SAMTOOLS_UMICOLLAPSE_TRANSCRIPTOME } from '../bam_dedup_stats_samtools_umicollapse'
include { BAM_DEDUP_STATS_SAMTOOLS_UMICOLLAPSE as BAM_DEDUP_STATS_SAMTOOLS_UMICOLLAPSE_GENOME        } from '../bam_dedup_stats_samtools_umicollapse'
```

**Best Practices:**

- Use descriptive aliases that indicate the context or purpose
- Keep aliases consistent across the pipeline
- Document aliases in comments if the purpose isn't obvious

### 3. Path Conventions

Use relative paths consistently:

```groovy
// Modules: ../../../modules/nf-core/module_name/main
include { MODULE } from '../../../modules/nf-core/module_name/main'

// Subworkflows: ../subworkflow_name
include { SUBWORKFLOW } from '../subworkflow_name'

// Local modules: ../../../modules/local/module_name/main
include { LOCAL_MODULE } from '../../../modules/local/module_name/main'
```

---

## Input/Output Definitions

### 1. Input Channel Structure (`take:`)

Define all inputs clearly with comments:

```groovy
workflow SUBWORKFLOW_NAME {
    take:
    ch_reads             // channel: [ val(meta), [ reads ] ]
    ch_fasta             // channel: /path/to/genome.fasta
    ch_gtf               // channel: /path/to/genome.gtf
    ch_index             // channel: /path/to/index/ (optional)
    skip_step            // boolean: true/false
    min_reads            // integer: > 0
    tool_param           // string: Tool-specific parameter
```

**Best Practices:**

- Use descriptive channel names with `ch_` prefix
- Include type information in comments
- Mark optional inputs in comments
- Group related inputs together
- Use clear, descriptive parameter names

### 2. Output Channel Structure (`emit:`)

Define all outputs with clear descriptions:

```groovy
emit:
reads           = ch_processed_reads           // channel: [ val(meta), [ reads ] ]
results         = MODULE.out.results           // channel: [ val(meta), results_dir ]
stats           = MODULE.out.stats             // channel: [ val(meta), path(stats) ]
multiqc_files   = ch_multiqc_files             // channel: file
versions        = ch_versions                  // channel: [ versions.yml ]
```

**Best Practices:**

- Emit all outputs that downstream workflows might need
- Use descriptive output names
- Include type information in comments
- Group related outputs together
- Always emit `versions` channel

### 3. Conditional Outputs

Handle outputs that may or may not be generated:

```groovy
emit:
reads           = ch_processed_reads
stats           = skip_stats ? channel.empty() : MODULE.out.stats
versions        = ch_versions
```

---

## Channel Management

### 1. Initialize Channel Variables

Initialize channel variables at the start of the `main:` block:

```groovy
main:

ch_versions = channel.empty()
ch_multiqc_files = channel.empty()
ch_processed_reads = channel.empty()
ch_stats = channel.empty()
```

### 2. Channel Mixing

Use `.mix()` to combine channels:

```groovy
// Mix version channels
ch_versions = ch_versions.mix(MODULE1.out.versions.first())
ch_versions = ch_versions.mix(MODULE2.out.versions.first())

// Mix MultiQC files
ch_multiqc_files = ch_multiqc_files.mix(MODULE1.out.html)
ch_multiqc_files = ch_multiqc_files.mix(MODULE2.out.json)
```

### 3. Channel Branching

Use `.branch()` to split channels based on conditions:

```groovy
ch_reads
    .branch { meta, reads ->
        single: meta.single_end
            return [meta, reads]
        paired: !meta.single_end
            return [meta, reads]
    }
    .set { ch_reads_by_type }

// Use branched channels
MODULE_SINGLE(ch_reads_by_type.single)
MODULE_PAIRED(ch_reads_by_type.paired)
```

### 4. Channel Joining

Use `.join()` to combine related channels:

```groovy
// Join BAM with index
ch_bam_with_index = ch_bam
    .join(ch_bai)

// Join with metadata-based key
ch_joined = ch_data
    .map { meta, data -> [meta.id, meta, data] }
    .join(
        ch_metadata.map { meta, metadata -> [meta.id, metadata] }
    )
    .map { id, meta, data, metadata -> [meta, data, metadata] }
```

### 5. Channel Filtering

Filter channels based on conditions:

```groovy
// Filter based on metadata
ch_filtered = ch_data
    .filter { meta, data -> meta.sample_type == 'riboseq' }

// Filter based on values
ch_passed = ch_results
    .filter { meta, count -> count >= min_reads }
```

### 6. Channel Transformation

Transform channels using `.map()`:

```groovy
// Transform metadata
ch_transformed = ch_data
    .map { meta, data -> 
        [meta + [processed: true], data] 
    }

// Extract specific values
ch_counts = ch_results
    .map { meta, results -> [meta, results.read_count] }
```

---

## Conditional Logic

### 1. Conditional Module Execution

Use `if` statements for optional modules:

```groovy
main:

if (!skip_fastqc) {
    FASTQC_RAW(ch_reads)
    ch_versions = ch_versions.mix(FASTQC_RAW.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_RAW.out.zip)
}
```

### 2. Mutually Exclusive Modules

Use `if-else if` for mutually exclusive options:

```groovy
if (trimmer == 'trimgalore') {
    FASTQ_FASTQC_UMITOOLS_TRIMGALORE(
        ch_reads,
        skip_fastqc,
        with_umi,
        skip_umi_extract,
        skip_trimming,
        umi_discard_read,
        min_trimmed_reads
    )
    ch_processed_reads = FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads
    ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.versions)
} else if (trimmer == 'fastp') {
    FASTQ_FASTQC_UMITOOLS_FASTP(
        ch_reads,
        skip_fastqc,
        with_umi,
        skip_umi_extract,
        umi_discard_read,
        skip_trimming,
        save_trimmed,
        fastp_merge,
        min_trimmed_reads
    )
    ch_processed_reads = FASTQ_FASTQC_UMITOOLS_FASTP.out.reads
    ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_FASTP.out.versions)
}
```

### 3. Conditional Channel Assignment

Assign channels conditionally:

```groovy
// Conditional index creation
if (make_index) {
    ch_index = MODULE_INDEX(ch_inputs).index
    ch_versions = ch_versions.mix(MODULE_INDEX.out.versions)
} else {
    ch_index = ch_provided_index
}

// Use the index
MODULE_USE_INDEX(ch_data, ch_index)
```

### 4. Nested Conditionals

Handle complex conditional logic:

```groovy
if (remove_ribo_rna) {
    if (ncrna_filter_tool == 'bowtie') {
        BOWTIE_ALIGN(ch_reads, ch_bowtie_index)
        ch_filtered_reads = BOWTIE_ALIGN.out.reads
        ch_versions = ch_versions.mix(BOWTIE_ALIGN.out.versions.first())
    } else {
        // Use SortMeRNA (default)
        SORTMERNA(ch_reads, ch_rrna_fastas, ch_sortmerna_index)
        ch_filtered_reads = SORTMERNA.out.reads
        ch_versions = ch_versions.mix(SORTMERNA.out.versions.first())
    }
}
```

---

## Version Tracking

### 1. Collect All Versions

#### Approach 1: Manual Channel Mixing (Traditional)

Always collect versions from all executed modules:

```groovy
main:

ch_versions = channel.empty()

// Collect versions after each module
MODULE1(ch_inputs)
ch_versions = ch_versions.mix(MODULE1.out.versions.first())

MODULE2(MODULE1.out.results)
ch_versions = ch_versions.mix(MODULE2.out.versions.first())

// Emit combined versions
emit:
versions = ch_versions  // channel: [ versions.yml ]
```

#### Approach 2: Topic Channels (Nextflow 24.04+, Recommended)

Use topic channels for automatic version collection (simpler and cleaner):

```groovy
main:

// Define topic channel for versions
topic versions

// Modules automatically publish to topic channel
MODULE1(ch_inputs)
MODULE2(MODULE1.out.results)

// Topic channel automatically collects all versions
emit:
versions = versions  // channel: [ versions.yml ]
```

**Benefits of Topic Channels:**

- **Automatic collection**: No need for manual `.mix()` calls
- **Cleaner code**: Reduces boilerplate
- **Less error-prone**: Can't forget to collect versions
- **Works with conditionals**: Automatically handles optional modules

**Requirements:**

- Nextflow version 24.04 or later
- Modules must emit versions to a topic channel (using `topic: versions` in output definition)

**Example with Conditional Modules:**

```groovy
main:

topic versions

// Versions automatically collected even with conditionals
if (!skip_module) {
    MODULE(ch_inputs)
    // No need to manually mix - topic channel handles it
}

emit:
versions = versions
```

**Note:** If using topic channels, ensure modules are configured to emit to the topic:

```groovy
// In module main.nf
output:
path "versions.yml", topic: versions  // Emits to topic channel
```

### 2. Handle Optional Modules

#### Manual Mixing Approach

Only collect versions from modules that actually run:

```groovy
ch_versions = channel.empty()

if (!skip_module) {
    MODULE(ch_inputs)
    ch_versions = ch_versions.mix(MODULE.out.versions.first())
}
```

#### Topic Channels Approach

Topic channels automatically handle optional modules:

```groovy
topic versions

if (!skip_module) {
    MODULE(ch_inputs)
    // Versions automatically collected if module runs
}

emit:
versions = versions
```

### 3. Subworkflow Versions

#### Manual Mixing for Subworkflows

When including subworkflows, collect their versions:

```groovy
SUBWORKFLOW(ch_inputs)
ch_versions = ch_versions.mix(SUBWORKFLOW.out.versions)
```

#### Topic Channels for Subworkflows

Subworkflows can also use topic channels:

```groovy
topic versions

SUBWORKFLOW(ch_inputs)
// Versions automatically collected from subworkflow

emit:
versions = versions
```

**Best Practice:** Use topic channels when using Nextflow 24.04+ for cleaner, more maintainable code. Fall back to manual mixing for compatibility with older Nextflow versions.

---

## Helper Functions

### 1. Function Definition

Define helper functions before the workflow:

```groovy
//
// Function to calculate strandedness from Salmon output
//
def calculateStrandedness(forwardFragments, reverseFragments, unstrandedFragments, stranded_threshold = 0.8, unstranded_threshold = 0.1) {
    def totalFragments = forwardFragments + reverseFragments + unstrandedFragments
    def totalStrandedFragments = forwardFragments + reverseFragments

    def strandedness = 'undetermined'
    if (totalStrandedFragments > 0) {
        def forwardProportion = forwardFragments / (totalStrandedFragments as double)
        def reverseProportion = reverseFragments / (totalStrandedFragments as double)
        def proportionDifference = Math.abs(forwardProportion - reverseProportion)

        if (forwardProportion >= stranded_threshold) {
            strandedness = 'forward'
        } else if (reverseProportion >= stranded_threshold) {
            strandedness = 'reverse'
        } else if (proportionDifference <= unstranded_threshold) {
            strandedness = 'unstranded'
        }
    }

    return [
        inferred_strandedness: strandedness,
        forwardFragments: (forwardFragments / (totalFragments as double)) * 100,
        reverseFragments: (reverseFragments / (totalFragments as double)) * 100,
        unstrandedFragments: (unstrandedFragments / (totalFragments as double)) * 100
    ]
}

//
// Function to parse JSON and extract values
//
def getFastpReadsAfterFiltering(json_file, min_num_reads) {
    if (workflow.stubRun) {
        return min_num_reads
    }
    def json = new groovy.json.JsonSlurper().parseText(json_file.text).get('summary') as Map
    return json['after_filtering']['total_reads'].toLong()
}

workflow SUBWORKFLOW_NAME {
    // Use functions in workflow
}
```

### 2. Function Best Practices

- **Document functions**: Add comments explaining purpose and parameters
- **Handle stub runs**: Check `workflow.stubRun` when parsing files
- **Return structured data**: Use maps/lists for complex return values
- **Provide defaults**: Use default parameter values when appropriate
- **Error handling**: Validate inputs and handle edge cases

---

## Documentation

### 1. Inline Comments

Add clear comments throughout the subworkflow:

```groovy
//
// MODULE: Concatenate FastQ files from same sample if required
//
CAT_FASTQ(ch_fastq.multiple)
ch_processed_reads = CAT_FASTQ.out.reads.mix(ch_fastq.single)

//
// SUBWORKFLOW: Read QC, extract UMI and trim adapters with TrimGalore!
//
if (trimmer == 'trimgalore') {
    FASTQ_FASTQC_UMITOOLS_TRIMGALORE(...)
}
```

### 2. Meta.yml File

Create comprehensive `meta.yml` documentation:

```yaml
name: "subworkflow_name"
description: Brief description of what the subworkflow does
keywords:
  - keyword1
  - keyword2
  - keyword3

components:
  - module1/process1
  - module2/process2
  - other_subworkflow

input:
  - ch_input1:
      description: Description of input channel
      structure:
        - meta:
            type: map
            description: Metadata map
        - data:
            type: file
            description: Input data file
            pattern: "*.{ext1,ext2}"

output:
  - output1:
      description: Description of output channel
      structure:
        - meta:
            type: map
            description: Metadata map
        - results:
            type: file
            description: Output results file
            pattern: "*.results"

authors:
  - "@github_username"
maintainers:
  - "@github_username"
```

**Best Practices:**

- Provide clear, concise descriptions
- List all component modules/subworkflows
- Document input/output channel structures
- Include file patterns where applicable
- List authors and maintainers

---

## Testing

### 1. Test File Structure

Create test files for subworkflows:

```groovy
// tests/main.nf.test
nextflow.enable.dsl = 2

include { SUBWORKFLOW_NAME } from '../main.nf'

workflow test_subworkflow {
    // Create test input channels
    ch_test_input = channel.of([[:], file('test_input.txt')])
    
    SUBWORKFLOW_NAME(
        ch_test_input,
        // ... other test inputs
    )
}
```

### 2. Test Configuration

Create test configuration files:

```groovy
// tests/nextflow.config
process {
    withName: '.*' {
        publishDir = [
            path: { "${params.outdir}/${task.process.tokenize(':')[-1]}" },
            mode: 'copy'
        ]
    }
}

params {
    outdir = 'test_results'
}
```

### 3. Test Best Practices

- Test with minimal data
- Test all conditional branches
- Verify output channels are correctly emitted
- Test with stub runs when possible
- Include edge cases (empty channels, single samples, etc.)

---

## Common Patterns

### 1. Sequential Processing

Chain modules in sequence:

```groovy
// Step 1: Process input
MODULE1(ch_inputs)
ch_step1 = MODULE1.out.results

// Step 2: Process step 1 output
MODULE2(ch_step1)
ch_step2 = MODULE2.out.results

// Step 3: Final processing
MODULE3(ch_step2)
```

### 2. Parallel Processing

Process multiple inputs in parallel:

```groovy
// Process genome and transcriptome in parallel
MODULE_GENOME(ch_genome_inputs)
MODULE_TRANSCRIPTOME(ch_transcriptome_inputs)

// Combine results
ch_combined = MODULE_GENOME.out.results
    .mix(MODULE_TRANSCRIPTOME.out.results)
```

### 3. Conditional Index Creation

Create indices conditionally:

```groovy
if (make_index) {
    ch_index = MODULE_INDEX(ch_reference).index
    ch_versions = ch_versions.mix(MODULE_INDEX.out.versions)
} else {
    ch_index = ch_provided_index
}

// Use index
MODULE_USE_INDEX(ch_data, ch_index)
```

### 4. Metadata Transformation

Transform metadata through the workflow:

```groovy
// Add strandedness information
ch_data
    .join(ch_strand_info)
    .map { meta, data, strand_info ->
        [meta + [strandedness: strand_info.strandedness], data]
    }
    .set { ch_annotated_data }
```

### 5. MultiQC File Collection

Collect files for MultiQC:

```groovy
ch_multiqc_files = channel.empty()

// Collect from multiple modules
ch_multiqc_files = ch_multiqc_files.mix(MODULE1.out.html)
ch_multiqc_files = ch_multiqc_files.mix(MODULE2.out.json)
ch_multiqc_files = ch_multiqc_files.mix(MODULE3.out.log)

// Transform for MultiQC (remove metadata, keep files)
emit:
multiqc_files = ch_multiqc_files.transpose().map { entry -> entry[1] }
```

### 6. Filtering Based on Results

Filter outputs based on processing results:

```groovy
// Get read counts after processing
MODULE.out.reads
    .join(MODULE.out.stats)
    .map { meta, reads, stats ->
        def read_count = parseReadCount(stats)
        [meta, reads, read_count]
    }
    .filter { meta, reads, count -> count >= min_reads }
    .map { meta, reads, count -> [meta, reads] }
    .set { ch_passed_reads }
```

---

## Example Templates

### 1. Simple Sequential Subworkflow

```groovy
//
// Simple sequential processing subworkflow
//

include { MODULE1 } from '../../../modules/nf-core/module1/main'
include { MODULE2 } from '../../../modules/nf-core/module2/main'

workflow SIMPLE_SUBWORKFLOW {
    take:
    ch_inputs    // channel: [ val(meta), path(input) ]
    param1       // val: Parameter value

    main:

    ch_versions = channel.empty()

    //
    // Step 1: Initial processing
    //
    MODULE1(ch_inputs)
    ch_versions = ch_versions.mix(MODULE1.out.versions.first())

    //
    // Step 2: Secondary processing
    //
    MODULE2(MODULE1.out.results, param1)
    ch_versions = ch_versions.mix(MODULE2.out.versions.first())

    emit:
    results  = MODULE2.out.results  // channel: [ val(meta), results_dir ]
    versions = ch_versions          // channel: [ versions.yml ]
}
```

### 2. Conditional Processing Subworkflow

```groovy
//
// Subworkflow with conditional module execution
//

include { MODULE_A } from '../../../modules/nf-core/module_a/main'
include { MODULE_B } from '../../../modules/nf-core/module_b/main'
include { MODULE_C } from '../../../modules/nf-core/module_c/main'

workflow CONDITIONAL_SUBWORKFLOW {
    take:
    ch_inputs      // channel: [ val(meta), path(input) ]
    use_module_a   // boolean: Use module A
    use_module_b   // boolean: Use module B
    tool_choice    // string: 'tool1' or 'tool2'

    main:

    ch_versions = channel.empty()
    ch_processed = ch_inputs

    //
    // Optional step A
    //
    if (use_module_a) {
        MODULE_A(ch_processed)
        ch_processed = MODULE_A.out.results
        ch_versions = ch_versions.mix(MODULE_A.out.versions.first())
    }

    //
    // Mutually exclusive tool choice
    //
    if (tool_choice == 'tool1') {
        MODULE_B(ch_processed)
        ch_final = MODULE_B.out.results
        ch_versions = ch_versions.mix(MODULE_B.out.versions.first())
    } else if (tool_choice == 'tool2') {
        MODULE_C(ch_processed)
        ch_final = MODULE_C.out.results
        ch_versions = ch_versions.mix(MODULE_C.out.versions.first())
    }

    //
    // Optional step B
    //
    if (use_module_b) {
        MODULE_B(ch_final)
        ch_final = MODULE_B.out.results
        ch_versions = ch_versions.mix(MODULE_B.out.versions.first())
    }

    emit:
    results  = ch_final    // channel: [ val(meta), results_dir ]
    versions = ch_versions // channel: [ versions.yml ]
}
```

### 3. Complex Multi-Step Subworkflow

```groovy
//
// Complex subworkflow with branching, joining, and helper functions
//

include { MODULE1 } from '../../../modules/nf-core/module1/main'
include { MODULE2 } from '../../../modules/nf-core/module2/main'
include { MODULE3 } from '../../../modules/nf-core/module3/main'
include { SUBWORKFLOW } from '../other_subworkflow'

//
// Helper function to process results
//
def processResults(data, threshold) {
    // Process and return results
    return processed_data
}

workflow COMPLEX_SUBWORKFLOW {
    take:
    ch_inputs           // channel: [ val(meta), path(input) ]
    ch_reference         // channel: path(reference)
    make_index          // boolean: Create index
    filter_threshold    // integer: Filtering threshold

    main:

    ch_versions = channel.empty()
    ch_multiqc_files = channel.empty()

    //
    // Branch inputs by type
    //
    ch_inputs
        .branch { meta, input ->
            type_a: meta.type == 'type_a'
                return [meta, input]
            type_b: meta.type == 'type_b'
                return [meta, input]
        }
        .set { ch_by_type }

    //
    // Conditional index creation
    //
    if (make_index) {
        ch_index = MODULE1(ch_reference).index
        ch_versions = ch_versions.mix(MODULE1.out.versions.first())
    } else {
        ch_index = ch_provided_index
    }

    //
    // Process type A
    //
    MODULE2(ch_by_type.type_a, ch_index)
    ch_versions = ch_versions.mix(MODULE2.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(MODULE2.out.stats)

    //
    // Process type B using subworkflow
    //
    SUBWORKFLOW(ch_by_type.type_b, ch_reference)
    ch_versions = ch_versions.mix(SUBWORKFLOW.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(SUBWORKFLOW.out.multiqc_files)

    //
    // Combine and filter results
    //
    ch_combined = MODULE2.out.results
        .mix(SUBWORKFLOW.out.results)
        .map { meta, results ->
            def processed = processResults(results, filter_threshold)
            [meta, processed]
        }
        .filter { meta, processed -> processed.passed }

    //
    // Final processing
    //
    MODULE3(ch_combined)
    ch_versions = ch_versions.mix(MODULE3.out.versions.first())

    emit:
    results       = MODULE3.out.results                    // channel: [ val(meta), results_dir ]
    multiqc_files = ch_multiqc_files.transpose().map { entry -> entry[1] }  // channel: file
    versions      = ch_versions                            // channel: [ versions.yml ]
}
```

---

## Summary Checklist

When creating or reviewing a subworkflow:

- [ ] Clear file structure with `main.nf` and `meta.yml`
- [ ] All module includes at the top with proper paths
- [ ] Descriptive aliases for reused modules
- [ ] Clear input definitions with type comments
- [ ] All outputs properly emitted with descriptions
- [ ] Channel variables initialized at start of `main:`
- [ ] Versions collected from all executed modules
- [ ] Conditional logic handles all parameter combinations
- [ ] Helper functions documented and handle stub runs
- [ ] Channel operations (mix, join, branch, filter) used appropriately
- [ ] Comments explain complex logic and workflow steps
- [ ] `meta.yml` documents all components, inputs, and outputs
- [ ] Test files created for validation
- [ ] Edge cases handled (empty channels, single samples, etc.)

---

## References

- [Nextflow Workflow Documentation](https://www.nextflow.io/docs/latest/workflow.html)
- [nf-core Subworkflow Guidelines](https://nf-co.re/docs/contributing/subworkflows)
- Current pipeline subworkflows: `subworkflows/nf-core/*/main.nf`
- Current pipeline local subworkflows: `subworkflows/local/*/main.nf`
