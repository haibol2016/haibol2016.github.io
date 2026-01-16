---
layout: post
title: "Best Practices for Writing modules.config Files"
date: 2025-12-25
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, modules, configuration, bioinformatics, workflows, best-practices]
author: Haibo Liu, PhD
toc: true
excerpt: "Best practices for organizing and writing modules.config files for Nextflow pipelines with many modules and complex conditional execution logic, including file structure, configuration patterns, and publishing paths."
---
This document outlines best practices for organizing and writing `conf/modules.config` files for Nextflow pipelines with many modules and complex conditional execution logic.


## File Structure and Organization

### 1. Header Comment

Always start with a clear header comment explaining the file's purpose and available configuration keys:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Config file for defining DSL2 per module options and publishing paths
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Available keys to override module options:
        ext.args   = Additional arguments appended to command in module.
        ext.args2  = Second set of arguments appended to command in module (multi-tool modules).
        ext.args3  = Third set of arguments appended to command in module (multi-tool modules).
        ext.prefix = File name prefix for output files.
----------------------------------------------------------------------------------------
*/
```

### 2. General Configuration First

Place global/default configurations at the top of the file, before any conditional blocks:

```groovy
//
// General configuration options
//

process {
    publishDir = [
        path: { "${params.outdir}/${task.process.tokenize(':')[-1].tokenize('_')[0].toLowerCase()}" },
        mode: params.publish_dir_mode,
        saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
    ]
}
```

**Rationale:** This provides a sensible default for all modules, reducing redundancy and making it clear what the baseline behavior is.

---

## Section Organization

### 1. Organize by Workflow Stage

Group modules by their position in the analysis pipeline:

```groovy
//
// Genome preparation options
//

//
// Read subsampling and strand inferring options
//

//
// Linting options
//

//
// Read QC and trimming options
//

//
// Contaminant removal options
//

//
// Alignment options
//

//
// Reporting options
//

//
// Ribo-seq analysis options
//

//
// Differential analysis options
//
```

**Benefits:**

- Easy to locate module configurations
- Logical flow matches pipeline execution
- Clear separation of concerns

### 2. Use Clear Section Headers

Use consistent comment style with double slashes (`//`) and descriptive section names:

```groovy
//
// Section Name - Brief Description
//
```

### 3. Order Sections by Execution Flow

Arrange sections in the order modules are executed in the workflow, from input preparation to final reporting.

---

## Conditional Logic Patterns

### 1. Use `if` Blocks for Optional Modules

Wrap configurations for optional modules in conditional blocks that match workflow logic:

```groovy
if (!params.skip_ribocode) {
    process {
        withName: 'RIBOCODE_QUALITY' {
            ext.args   = { params.extra_ribocode_quality_args ?: '' }
            publishDir = [
                path: { "${params.outdir}/riboseq_qc/ribocode" },
                mode: params.publish_dir_mode,
                saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
            ]
        }
    }
}
```

**Key Points:**

- Condition should match the workflow's conditional logic exactly
- Use `!params.skip_*` pattern for skip flags
- Keep related modules within the same conditional block

### 2. Use `if-else if` for Mutually Exclusive Options

When modules are mutually exclusive (e.g., different trimmers), use `if-else if`:

```groovy
if (params.trimmer == 'trimgalore' && !params.skip_trimming) {
    process {
        withName: '.*:FASTQ_FASTQC_UMITOOLS_TRIMGALORE:TRIMGALORE' {
            // trimgalore configuration
        }
    }
} else if (params.trimmer == 'fastp' && !params.skip_trimming) {
    process {
        withName: '.*:FASTQ_FASTQC_UMITOOLS_FASTP:FASTP' {
            // fastp configuration
        }
    }
}
```

**Benefits:**

- Clearer than nested `if` statements
- Prevents conflicting configurations
- Easier to extend with additional options

### 3. Combine Related Conditions

When multiple conditions must be met, combine them logically:

```groovy
// Ribo-seq QC validation (requires RiboCode)
if (!params.skip_ribocode && !params.skip_qc_validation) {
    process {
        withName: 'VALIDATE_RIBOSEQ_QC' {
            // configuration
        }
    }
}
```

### 4. Match Workflow Logic Exactly

Ensure conditional logic in `modules.config` matches the workflow's conditional execution:

```groovy
// In workflow: if (!params.skip_bbsplit && params.bbsplit_fasta_list)
// In modules.config:
if (!params.skip_bbsplit && params.bbsplit_fasta_list) {
    process {
        withName: '.*:PREPARE_GENOME:BBMAP_BBSPLIT' {
            // configuration
        }
    }
}
```

**Validation:** Cross-reference with `workflows/*/main.nf` to ensure conditions match.

---

## Module Grouping Strategies

### 1. Consolidate Identical Configurations

Use regex alternation (`|`) to group modules with identical configurations:

```groovy
// Common genome preparation modules with identical publishDir config
withName: 'CUSTOM_CATADDITIONALFASTA|PREPROCESS_TRANSCRIPTS_FASTA_GENCODE|GTF_FILTER|CUSTOM_GETCHROMSIZES|.*:PREPARE_GENOME:GFFREAD' {
    publishDir = [
        path: { "${params.outdir}/genome" },
        mode: params.publish_dir_mode,
        saveAs: { filename -> filename.equals('versions.yml') ? null : params.save_reference ? filename : null }
    ]
}
```

**Benefits:**

- Reduces duplication
- Easier to maintain
- Single source of truth

### 2. Group Aliased Module Instances

When the same module is used multiple times with different aliases, consolidate shared configurations:

```groovy
// Common RIBOORF configuration (INDIVIDUAL and ALL use same args)
withName: 'RIBOORF_PREDICT_INDIVIDUAL|RIBOORF_PREDICT_ALL' {
    ext.args   = { params.extra_riboorf_args ?: '' }
}

// Then specify unique configurations separately
withName: 'RIBOORF_PREDICT_INDIVIDUAL' {
    publishDir = [
        path: { "${params.outdir}/orf_predictions/riboorf" },
        // ...
    ]
}

withName: 'RIBOORF_PREDICT_ALL' {
    publishDir = [
        path: { "${params.outdir}/orf_predictions/riboorf_all" },
        // ...
    ]
}
```

**Pattern:**

1. Define shared `ext.args` using regex alternation
2. Define unique `publishDir` for each alias separately

### 3. Group by Subworkflow Context

Use full module paths (including subworkflow context) when modules appear in different contexts:

```groovy
// Matches GFFREAD only when called within PREPARE_GENOME subworkflow
withName: '.*:PREPARE_GENOME:GFFREAD' {
    ext.args   = { params.extra_gffread_args ?: '--keep-exon-attrs -F -T' }
}

// Matches GFFREAD when used as MAKE_TRANSCRIPTS_FASTA
withName: '.*:PREPARE_GENOME:MAKE_TRANSCRIPTS_FASTA' {
    ext.args   = { params.extra_make_transcripts_fasta_args ?: '-w' }
}
```

---

## Configuration Patterns

### 1. Parameter Exposure Pattern

Expose hardcoded values as configurable parameters:

```groovy
withName: 'BBMAP_BBSPLIT' {
    ext.args   = { params.extra_bbsplit_args ?: 'build=1 ambiguous2=all maxindel=150000 ow=f' }
}
```

**Pattern:**

- Use `params.extra_*_args` for additional arguments
- Provide sensible defaults using the Elvis operator (`?:`)
- Document parameters in `nextflow_schema.json`

### 2. Complex Argument Building

For modules with many parameters, build arguments from lists:

```groovy
withName: 'STAR_ALIGN' {
    ext.args   = { [
        '--alignSJDBoverhangMin 1',
        '--alignEndsType EndToEnd',
        '--outFilterMultimapNmax 20',
        params.save_unaligned ? '--outReadsUnmapped Fastx' : '',
        '--outSAMattributes All',
        params.extra_star_align_args ? params.extra_star_align_args.split("\\s(?=--)") : ''
    ].flatten().unique(false).join(' ').trim() }
}
```

**Key Techniques:**

- Use lists for clarity and maintainability
- Use conditional inclusion (`? : ''`)
- Use `flatten()` and `unique(false)` to handle nested lists
- Use `trim()` to remove extra whitespace
- Split user-provided args on flag boundaries

### 3. Multiple Publish Directories

Use arrays for multiple publish directories with different patterns:

```groovy
withName: '.*:FASTQ_FASTQC_UMITOOLS_TRIMGALORE:TRIMGALORE' {
    publishDir = [
        [
            path: { "${params.outdir}/preprocessing/${params.trimmer}/fastqc" },
            mode: params.publish_dir_mode,
            pattern: "*.{html,zip}"
        ],
        [
            path: { "${params.outdir}/preprocessing/${params.trimmer}" },
            mode: params.publish_dir_mode,
            pattern: "*.fq.gz",
            saveAs: { params.save_trimmed ? it : null }
        ],
        [
            path: { "${params.outdir}/preprocessing/${params.trimmer}" },
            mode: params.publish_dir_mode,
            pattern: "*.txt"
        ]
    ]
}
```

**Pattern:**

- Separate directories for different file types
- Use `pattern` to match specific file extensions
- Use `saveAs` closures for conditional saving

### 4. Conditional Saving

Use `saveAs` closures for conditional file publishing:

```groovy
publishDir = [
    path: { "${params.outdir}/preprocessing/bbsplit" },
    mode: params.publish_dir_mode,
    pattern: '*.fastq.gz',
    saveAs: { params.save_bbsplit_reads ? it : null }
]
```

**Pattern:**

- Return `null` to prevent saving
- Return `it` (filename) to save
- Use parameter flags to control behavior

---

## Naming Conventions

### 1. Parameter Names

Use consistent naming patterns:

- `extra_*_args` - Additional command-line arguments
- `extra_*_index_args` - Arguments for index-building steps
- `skip_*` - Boolean flags to skip modules
- `save_*` - Boolean flags to save intermediate files

### 2. Module Selectors

Use descriptive regex patterns:

```groovy
// Good: Clear and specific
withName: '.*:BAM_DEDUP_STATS_SAMTOOLS_UMICOLLAPSE_GENOME:UMICOLLAPSE'

// Good: Groups related modules
withName: 'RIBOCODE_DETECT_ORFS_INDIVIDUAL|RIBOCODE_DETECT_ORFS_ALL'

// Avoid: Overly broad patterns that might match unintended modules
withName: '.*SORT.*'  // Too broad!
```

### 3. Section Names

Use consistent section naming:

- Use plural nouns: "options", "configurations"
- Match workflow terminology
- Be specific: "Read QC and trimming options" not "QC options"

---

## Comments and Documentation

### 1. Section Comments

Always include section headers with brief descriptions:

```groovy
//
// Contaminant removal options
//
```

### 2. Inline Comments

Add comments for complex logic or non-obvious configurations:

```groovy
// Common FastQC configuration for raw reads (trimgalore and fastp)
// Matches both: TRIMGALORE:FASTQC and FASTP:FASTQC_RAW (both use same config)
withName: '.*:FASTQ_FASTQC_UMITOOLS_TRIMGALORE:FASTQC|.*:FASTQ_FASTQC_UMITOOLS_FASTP:FASTQC_RAW' {
    // ...
}
```

### 3. Conditional Logic Comments

Explain why conditions are needed:

```groovy
// Ribo-seq QC validation (requires RiboCode)
if (!params.skip_ribocode && !params.skip_qc_validation) {
    // ...
}

// Configuration for SAMTOOLS_SORT and UMITOOLS_PREPAREFORSALMON when UMIs are NOT used
// These modules are called directly in the workflow (not in BAM_DEDUP_UMI subworkflow)
if (!params.with_umi) {
    // ...
}
```

### 4. Workflow Alignment Comments

Document how configurations align with workflow logic:

```groovy
// Name-sort transcriptome BAM for Salmon preparation (when UMIs are not used)
// This matches SAMTOOLS_SORT called directly in the workflow (not in BAM_DEDUP_UMI)
withName: 'NFCORE_RIBOSEQ:RIBOSEQ:SAMTOOLS_SORT' {
    // ...
}
```

---

## Parameter Exposure

### 1. Expose All Hardcoded Values

Never hardcode values that users might want to customize:

```groovy
// Bad
ext.args = '--alignSJDBoverhangMin 1 --alignEndsType EndToEnd'

// Good
ext.args = { [
    '--alignSJDBoverhangMin 1',
    '--alignEndsType EndToEnd',
    params.extra_star_align_args ? params.extra_star_align_args.split("\\s(?=--)") : ''
].flatten().unique(false).join(' ').trim() }
```

### 2. Provide Sensible Defaults

Always provide defaults using the Elvis operator:

```groovy
ext.args = { params.extra_bbsplit_args ?: 'build=1 ambiguous2=all maxindel=150000 ow=f' }
```

### 3. Document in Schema

Add all exposed parameters to `nextflow_schema.json`:

```json
{
    "extra_bbsplit_args": {
        "type": "string",
        "description": "Additional arguments to pass to BBSplit alignment",
        "help_text": "This string will be appended to the default BBSplit arguments."
    }
}
```

### 4. Update Defaults in `nextflow.config`

Set parameter defaults in `nextflow.config`:

```groovy
params {
    extra_bbsplit_args = null
}
```

---

## Testing and Validation

### 1. Validate Conditional Logic

Cross-reference all conditional blocks with the main workflow:

```bash
# Check workflow conditions
grep -n "if.*skip_" workflows/*/main.nf

# Check modules.config conditions
grep -n "if.*skip_" conf/modules.config
```

### 2. Test All Conditional Paths

Ensure configurations work for all parameter combinations:

- Test with `skip_*` flags enabled/disabled
- Test mutually exclusive options (e.g., `trimmer: trimgalore` vs `fastp`)
- Test dependent conditions (e.g., `skip_ribocode && skip_qc_validation`)

### 3. Validate Module Selectors

Use Nextflow's `-dump-config` to verify module selectors match:

```bash
nextflow run main.nf -dump-config | grep -A 5 "withName"
```

### 4. Check for Redundancy

Regularly review for duplicate configurations that can be consolidated:

```bash
# Find similar publishDir configurations
grep -A 3 "publishDir" conf/modules.config | sort | uniq -d
```

---

## Common Pitfalls

### 1. Mixing `if` Statements with `process` Blocks

**Wrong:**

```groovy
process {
    if (params.skip_ribocode) {
        withName: 'RIBOCODE_QUALITY' {
            // This won't work!
        }
    }
}
```

**Correct:**

```groovy
if (!params.skip_ribocode) {
    process {
        withName: 'RIBOCODE_QUALITY' {
            // ...
        }
    }
}
```

### 2. Incorrect Conditional Logic

**Wrong:**

```groovy
// Module only runs when skip_ribocode is false, but condition checks for true
if (params.skip_ribocode) {
    process {
        withName: 'RIBOCODE_QUALITY' { }
    }
}
```

**Correct:**

```groovy
// Match the workflow's condition
if (!params.skip_ribocode) {
    process {
        withName: 'RIBOCODE_QUALITY' { }
    }
}
```

### 3. Overly Broad Regex Patterns

**Wrong:**

```groovy
withName: '.*SORT.*' {  // Matches too many modules!
    // ...
}
```

**Correct:**

```groovy
withName: 'SAMTOOLS_SORT|.*:BAM_SORT_STATS_SAMTOOLS.*:SAMTOOLS_SORT' {
    // ...
}
```

### 4. Missing Context in Module Selectors

**Wrong:**

```groovy
// This might match GFFREAD in multiple contexts
withName: 'GFFREAD' {
    // ...
}
```

**Correct:**

```groovy
// Specific to PREPARE_GENOME subworkflow
withName: '.*:PREPARE_GENOME:GFFREAD' {
    // ...
}
```

### 5. Hardcoded Values

**Wrong:**

```groovy
ext.args = '--threads 4 --memory 8G'
```

**Correct:**

```groovy
ext.args = { [
    "--threads ${task.cpus}",
    "--memory ${task.memory.toGiga()}G",
    params.extra_module_args ?: ''
].join(' ').trim() }
```

### 6. Inconsistent Parameter Naming

**Wrong:**

```groovy
// Mixed naming conventions
ext.args = { params.extra_args ?: '' }
ext.args = { params.additional_arguments ?: '' }
```

**Correct:**

```groovy
// Consistent naming
ext.args = { params.extra_module_args ?: '' }
```

---

## Example Template

Here's a complete example showing best practices:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Config file for defining DSL2 per module options and publishing paths
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Available keys to override module options:
        ext.args   = Additional arguments appended to command in module.
        ext.args2  = Second set of arguments appended to command in module (multi-tool modules).
        ext.args3  = Third set of arguments appended to command in module (multi-tool modules).
        ext.prefix = File name prefix for output files.
----------------------------------------------------------------------------------------
*/

//
// General configuration options
//

process {
    publishDir = [
        path: { "${params.outdir}/${task.process.tokenize(':')[-1].tokenize('_')[0].toLowerCase()}" },
        mode: params.publish_dir_mode,
        saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
    ]
}

//
// Section Name - Brief Description
//

// Optional: Unconditional configurations first
process {
    withName: 'MODULE_NAME' {
        ext.args   = { params.extra_module_args ?: '--default-arg value' }
        ext.prefix = { "${meta.id}.custom" }
        publishDir = [
            path: { "${params.outdir}/section_name" },
            mode: params.publish_dir_mode,
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }

    // Group modules with identical configurations
    withName: 'MODULE_A|MODULE_B|MODULE_C' {
        publishDir = [
            path: { "${params.outdir}/common" },
            mode: params.publish_dir_mode,
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
}

// Conditional configurations
if (!params.skip_module && params.required_param) {
    process {
        // Shared configuration for aliased modules
        withName: 'MODULE_ALIAS_1|MODULE_ALIAS_2' {
            ext.args = { params.extra_module_args ?: '' }
        }

        // Unique configurations per alias
        withName: 'MODULE_ALIAS_1' {
            publishDir = [
                path: { "${params.outdir}/module/alias1" },
                mode: params.publish_dir_mode,
                saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
            ]
        }

        withName: 'MODULE_ALIAS_2' {
            publishDir = [
                path: { "${params.outdir}/module/alias2" },
                mode: params.publish_dir_mode,
                saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
            ]
        }
    }
}

// Mutually exclusive options
if (params.option == 'choice1') {
    process {
        withName: 'MODULE_CHOICE1' {
            ext.args = { params.extra_choice1_args ?: '--choice1-default' }
            publishDir = [
                path: { "${params.outdir}/choice1" },
                mode: params.publish_dir_mode,
                saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
            ]
        }
    }
} else if (params.option == 'choice2') {
    process {
        withName: 'MODULE_CHOICE2' {
            ext.args = { params.extra_choice2_args ?: '--choice2-default' }
            publishDir = [
                path: { "${params.outdir}/choice2" },
                mode: params.publish_dir_mode,
                saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
            ]
        }
    }
}

// Complex argument building
if (!params.skip_complex_module) {
    process {
        withName: 'COMPLEX_MODULE' {
            ext.args = { [
                '--required-flag',
                '--another-flag value',
                params.conditional_param ? '--conditional-flag' : '',
                params.extra_complex_module_args ? params.extra_complex_module_args.split("\\s(?=--)") : ''
            ].flatten().unique(false).join(' ').trim() }
            publishDir = [
                [
                    path: { "${params.outdir}/complex/output1" },
                    mode: params.publish_dir_mode,
                    pattern: "*.type1"
                ],
                [
                    path: { "${params.outdir}/complex/output2" },
                    mode: params.publish_dir_mode,
                    pattern: "*.type2",
                    saveAs: { params.save_type2 ? it : null }
                ]
            ]
        }
    }
}
```

---

## Summary Checklist

When writing or reviewing `modules.config`:

- [ ] Header comment explains available configuration keys
- [ ] General/default configuration at the top
- [ ] Sections organized by workflow stage
- [ ] Clear section headers with descriptions
- [ ] Conditional logic matches workflow exactly
- [ ] Identical configurations consolidated using regex
- [ ] Aliased modules grouped appropriately
- [ ] All hardcoded values exposed as parameters
- [ ] Parameters documented in `nextflow_schema.json`
- [ ] Defaults set in `nextflow.config`
- [ ] Inline comments explain complex logic
- [ ] Module selectors are specific and correct
- [ ] No redundant configurations
- [ ] All conditional paths tested
- [ ] Consistent naming conventions

---

## References

- [Nextflow Configuration Documentation](https://www.nextflow.io/docs/latest/config.html)
- [nf-core Configuration Guidelines](https://nf-co.re/docs/contributing/modules#modulesconfig)
- Current pipeline: `conf/modules.config`
- Main workflow: `workflows/riboseq/main.nf`
