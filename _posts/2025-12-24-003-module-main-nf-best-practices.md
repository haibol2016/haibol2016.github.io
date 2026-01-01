---
layout: post
title: "Best Practices for Writing Module main.nf Files"
date: 2025-12-24
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, modules, main.nf, bioinformatics, workflows, best-practices]
author: Haibo Liu, PhD
toc: true
---
This document outlines best practices for writing Nextflow module `main.nf` files, with special focus on handling tools with many configurable parameters.


## Module Structure

### 1. Standard Process Definition

Every module should follow this basic structure:

```groovy
process MODULE_NAME {
    tag "$meta.id"
    label 'process_medium'  // or 'process_low', 'process_high', 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version--build' :
        'biocontainers/tool:version--build' }"

    input:
    // Input definitions

    output:
    // Output definitions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Script implementation

    stub:
    // Stub implementation
}
```

### 2. Process Labels

Use appropriate labels for resource allocation:

- `process_single`: Minimal resources (1 CPU, 2GB RAM)
- `process_low`: Low resources (2-4 CPUs, 4-8GB RAM)
- `process_medium`: Medium resources (4-8 CPUs, 8-16GB RAM)
- `process_high`: High resources (8+ CPUs, 16+ GB RAM)

**Example:**

```groovy
process STAR_ALIGN {
    label 'process_high'  // STAR requires significant resources
}
```

---

## Handling Many Parameters

### 1. Primary Strategy: `task.ext.args`

For tools with many parameters, use `task.ext.args` as the primary mechanism:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

"""
tool \\
    --required-flag value \\
    --another-flag \\
    $args \\
    input_file
"""
```

**Benefits:**

- Flexible: Users can pass any combination of parameters
- Maintainable: No need to expose every parameter individually
- Compatible: Works with `modules.config` for default arguments

### 2. Building Arguments from Lists

For tools where you need to set sensible defaults but allow overrides:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Build default arguments
def default_args = [
    '--alignSJDBoverhangMin 1',
    '--alignEndsType EndToEnd',
    '--outFilterMultimapNmax 20',
    params.save_unaligned ? '--outReadsUnmapped Fastx' : '',
    '--outSAMattributes All',
    '--outSAMstrandField intronMotif',
    '--outSAMtype BAM Unsorted',
    '--quantMode TranscriptomeSAM',
    '--readFilesCommand zcat',
    '--runRNGseed 0',
    '--twopassMode Basic'
]

// Split user-provided args on flag boundaries
def user_args = args ? args.split("\\s(?=--)") : []

// Combine and remove empty strings
def all_args = (default_args + user_args).flatten().unique(false).findAll { it != '' }.join(' ')

"""
tool \\
    --genomeDir $index \\
    --readFilesIn ${reads1.join(",")} \\
    --runThreadN $task.cpus \\
    $all_args
"""
```

**Key Techniques:**

- Use lists for clarity and maintainability
- Use conditional inclusion (`? : ''`)
- Split user args on flag boundaries: `"\\s(?=--)"`
- Use `flatten()` and `unique(false)` to handle nested lists
- Use `findAll { it != '' }` to remove empty strings
- Use `trim()` to remove extra whitespace

### 3. Conditional Parameter Inclusion

Handle parameters that depend on conditions:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Conditional parameters
def ignore_gtf = star_ignore_sjdbgtf ? '' : "--sjdbGTFfile $gtf"
def seq_platform_str = seq_platform ? "'PL:$seq_platform'" : ""
def seq_center_str = seq_center ? "'CN:$seq_center'" : ""

// Check if user already provided the argument
def attrRG = args.contains("--outSAMattrRGline") ? "" : 
    "--outSAMattrRGline 'ID:$prefix' $seq_center_str 'SM:$prefix' $seq_platform_str"

"""
tool \\
    $ignore_gtf \\
    $attrRG \\
    $args
"""
```

### 4. Parameter Validation

Validate required parameters or mutually exclusive options:

```groovy
script:
def args = task.ext.args ?: ''

// Validate mutually exclusive options
def prob_exists = args =~ /-p|--probability/
def nrec_exists = args =~ /-n|--record-count/
if (!(prob_exists || nrec_exists)) {
    error "MODULE requires --probability (-p) or --record-count (-n) specified in task.ext.args!"
}

"""
tool $args input_file
"""
```

---

## Input/Output Definitions

### 1. Input Channel Structure

Use tuples for structured data:

```groovy
input:
tuple val(meta), path(reads)                    // Single input file
tuple val(meta), path(reads), path(adapter_fasta)  // Multiple input files
tuple val(meta), path(reads), val(flag1), val(flag2)  // Files + metadata
```

**Best Practices:**

- Always include `meta` as the first element for sample tracking
- Use `val()` for metadata and non-file values
- Use `path()` for files that need staging
- Use `stageAs` for complex file patterns:

```groovy
tuple val(meta), path(reads, stageAs: "input*/*")
```

### 2. Output Channel Structure

Define all possible outputs, marking optional ones:

```groovy
output:
tuple val(meta), path("*.bam")              , emit: bam
tuple val(meta), path("*.log")              , emit: log
tuple val(meta), path("*.json")             , emit: json, optional: true
tuple val(meta), path("*.html")             , emit: html, optional: true
path "versions.yml"                         , emit: versions
// more convenient to send version information to a topic channel (work only for recent nextflow)
// path "versions.yml"                         , topic: versions
```

**Best Practices:**

- Use `optional: true` for outputs that may not always be generated
- Use glob patterns (`*.bam`) for flexible file matching
- Always emit `versions.yml` for version tracking
- Use descriptive channel names (`emit: bam`, not `emit: out1`)

### 3. Output File Patterns

Use appropriate glob patterns:

```groovy
// Single file type
path("*.bam")

// Multiple file types
path("*.{bam,bai}")

// Pattern with optional compression
path("*.tsv{,.gz}")

// Directory contents
path("results/*")

// Specific prefix
path("${prefix}.bam")
```

### 4. Mutually Exclusive Inputs

When users can specify mutually exclusive input options, validate and handle them appropriately:

#### 4.1. Mutually Exclusive Parameters

Validate that users provide exactly one of mutually exclusive parameters:

```groovy
script:
def args = task.ext.args ?: ''

/* args requires:
    --probability <f64>: Probability read is kept, between 0 and 1. Mutually exclusive with record-count.
    --record-count <u64>: Number of records to keep. Mutually exclusive with probability
*/
def prob_exists = args =~ /-p|--probability/
def nrec_exists = args =~ /-n|--record-count/

// Require exactly one
if (!(prob_exists || nrec_exists)) {
    error "MODULE requires --probability (-p) OR --record-count (-n) specified in task.ext.args!"
}

// Optionally: Check that both aren't provided
if (prob_exists && nrec_exists) {
    error "MODULE: --probability and --record-count are mutually exclusive. Specify only one!"
}
```

#### 4.2. Mutually Exclusive Input Types

Handle different input types that are mutually exclusive:

```groovy
input:
tuple val(meta), path(reads)
val input_mode  // 'single', 'paired', or 'interleaved'

script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Validate input mode
def valid_modes = ['single', 'paired', 'interleaved']
if (input_mode && !valid_modes.contains(input_mode)) {
    error "MODULE: input_mode must be one of: ${valid_modes.join(', ')}"
}

// Handle mutually exclusive input types
if (input_mode == 'interleaved' || task.ext.args?.contains('--interleaved_in')) {
    """
    tool \\
        --in1 ${reads} \\
        --interleaved \\
        $args
    """
} else if (input_mode == 'paired' || reads instanceof List) {
    if (!(reads instanceof List) || reads.size() != 2) {
        error "MODULE: Paired-end mode requires exactly 2 input files!"
    }
    """
    tool \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        $args
    """
} else {
    // Single-end
    """
    tool \\
        --in1 ${reads} \\
        $args
    """
}
```

#### 4.3. Optional Inputs That Affect Behavior

Handle optional inputs that change module behavior:

```groovy
input:
tuple val(meta), path(bam), path(bai)
tuple val(meta2), path(fasta), path(gtf)
tuple val(meta3), path(offset_file)    // Optional input

script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Conditionally include optional parameter
def offset_arg = offset_file ? "--offset ${offset_file[1]}" : ""

"""
tool \\
    -b $bam \\
    -f $fasta \\
    -g $gtf \\
    $offset_arg \\
    -o ${prefix} \\
    $args
"""
```

**Best Practices:**

- Validate that mutually exclusive options aren't both provided
- Require at least one option when needed
- Provide clear error messages explaining the conflict
- Document mutual exclusivity in comments
- Use conditional logic to handle different input types

### 5. Mutually Exclusive Outputs

Handle outputs that are mutually exclusive based on user choices:

#### 5.1. Conditional Outputs Based on Parameters

Define outputs that may or may not be generated:

```groovy
output:
tuple val(meta), path("*.output.bam")        , emit: bam
tuple val(meta), path("*.output.sam")        , emit: sam, optional: true
tuple val(meta), path("*.output.cram")        , emit: cram, optional: true
path "versions.yml"                          , emit: versions

script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Determine output format from args
def output_format = 'bam'  // default
if (args.contains('--output-format sam')) {
    output_format = 'sam'
} else if (args.contains('--output-format cram')) {
    output_format = 'cram'
}

// Generate only the requested format
"""
tool \\
    --input $input \\
    --output-format $output_format \\
    --output ${prefix}.output.${output_format} \\
    $args
"""
```

#### 5.2. Mutually Exclusive Output Formats

When users can choose between output formats:

```groovy
output:
tuple val(meta), path("*.tsv")               , emit: tsv, optional: true
tuple val(meta), path("*.csv")               , emit: csv, optional: true
tuple val(meta), path("*.json")              , emit: json, optional: true
path "versions.yml"                          , emit: versions

script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Validate that only one format is specified
def format_count = 0
def output_format = null

if (args.contains('--format tsv') || args.contains('--tsv')) {
    format_count++
    output_format = 'tsv'
}
if (args.contains('--format csv') || args.contains('--csv')) {
    format_count++
    output_format = 'csv'
}
if (args.contains('--format json') || args.contains('--json')) {
    format_count++
    output_format = 'json'
}

if (format_count > 1) {
    error "MODULE: Only one output format (tsv, csv, or json) can be specified!"
}

// Default to tsv if none specified
if (!output_format) {
    output_format = 'tsv'
}

"""
tool \\
    --input $input \\
    --format $output_format \\
    --output ${prefix}.${output_format} \\
    $args
"""
```

#### 5.3. Conditional Outputs Based on Input Type

Generate different outputs based on input characteristics:

```groovy
output:
tuple val(meta), path("*.single.fastq.gz")  , emit: single, optional: true
tuple val(meta), path("*_1.fastq.gz")       , emit: paired1, optional: true
tuple val(meta), path("*_2.fastq.gz")       , emit: paired2, optional: true
tuple val(meta), path("*.merged.fastq.gz")  , emit: merged, optional: true
path "versions.yml"                         , emit: versions

script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"
def save_merged = args.contains('--merge') || params.save_merged

if (meta.single_end) {
    """
    tool \\
        --in1 ${reads} \\
        --out1 ${prefix}.single.fastq.gz \\
        $args
    """
} else {
    def merge_cmd = save_merged ? "-m --merged_out ${prefix}.merged.fastq.gz" : ''
    """
    tool \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${prefix}_1.fastq.gz \\
        --out2 ${prefix}_2.fastq.gz \\
        $merge_cmd \\
        $args
    """
}
```

#### 5.4. Post-Processing Based on Output Type

Handle file renaming or processing based on generated outputs:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

"""
tool \\
    --input $input \\
    --output ${prefix} \\
    $args

# Post-process based on what was generated
if [ -f ${prefix}_riboorf.txt ]; then
    mv ${prefix}_riboorf.txt ${prefix}.riboorf.txt
fi
if [ -f ${prefix}_all_riboorf.txt ]; then
    mv ${prefix}_all_riboorf.txt ${prefix}.all_riboorf.txt
fi
"""
```

**Best Practices:**

- Mark mutually exclusive outputs as `optional: true`
- Validate that users don't request conflicting output formats
- Provide sensible defaults when no format is specified
- Use conditional logic to generate only requested outputs
- Document which outputs are mutually exclusive in module metadata
- Handle post-processing for different output types appropriately

---

## Script Implementation

### 1. Variable Definitions

Define variables at the start of the script block:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Process input files
def reads1 = []
def reads2 = []
meta.single_end ? 
    [reads].flatten().each{ item -> reads1 << item } : 
    reads.eachWithIndex{ v, ix -> ( ix & 1 ? reads2 : reads1) << v }
```

### 2. Command Construction

Build commands clearly and handle edge cases:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Handle single-end vs paired-end
def input_reads = meta.single_end ? 
    "-r ${reads1.join(" ")}" : 
    "-1 ${reads1.join(" ")} -2 ${reads2.join(" ")}"

"""
tool \\
    --input $input_reads \\
    --threads $task.cpus \\
    --output $prefix \\
    $args
"""
```

### 3. Post-Processing

Handle file renaming, compression, or cleanup:

```groovy
script:
"""
tool $args input_file

# Post-processing
if [ -f ${prefix}.Unmapped.out.mate1 ]; then
    mv ${prefix}.Unmapped.out.mate1 ${prefix}.unmapped_1.fastq
    gzip ${prefix}.unmapped_1.fastq
fi

if [ -f ${prefix}.Unmapped.out.mate2 ]; then
    mv ${prefix}.Unmapped.out.mate2 ${prefix}.unmapped_2.fastq
    gzip ${prefix}.unmapped_2.fastq
fi
"""
```

### 4. Conditional Script Blocks

#### Approach 1: Build Command as Groovy List (Recommended)

Build the command as a Groovy list by conditionally adding elements to avoid duplication:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Build command parts as a list
def cmd = ['tool']

// Add input files conditionally
if (meta.single_end) {
    cmd += "--in1 ${reads}"
    cmd += "--out1 ${prefix}.output.fq.gz"
} else {
    cmd += "--in1 ${reads[0]}"
    cmd += "--in2 ${reads[1]}"
    cmd += "--out1 ${prefix}_1.output.fq.gz"
    cmd += "--out2 ${prefix}_2.output.fq.gz"
    if (save_merged) {
        cmd += "-m"
        cmd += "--merged_out ${prefix}.merged.fastq.gz"
    }
}

// Add user-provided arguments (split to handle multiple flags)
if (args) {
    def user_args = args.split("\\s(?=--)")
    cmd.addAll(user_args.findAll { it != '' })
}

"""
${cmd.join(' \\\n    ')}

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool: \$(tool --version 2>&1 | sed -e "s/tool //g")
END_VERSIONS
"""
```

**More Complex Example:**

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Build command parts
def cmd = ['tool']

// Common arguments
cmd += "--threads $task.cpus"
cmd += "--output $prefix"

// Conditional input handling
if (meta.single_end) {
    cmd += "--input ${reads}"
} else {
    cmd += "--input1 ${reads[0]}"
    cmd += "--input2 ${reads[1]}"
    if (save_merged) {
        cmd += "--merge"
        cmd += "--merged-output ${prefix}.merged.fq.gz"
    }
}

// Conditional flags
if (params.enable_feature) {
    cmd += "--enable-feature"
}

// Optional parameters
if (adapter_file) {
    cmd += "--adapters $adapter_file"
}

// User-provided arguments (split to handle multiple flags)
if (args) {
    def user_args = args.split("\\s(?=--)")
    cmd.addAll(user_args.findAll { it != '' })
}

// Join with proper line continuation
"""
${cmd.join(' \\\n    ')}

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool: \$(tool --version 2>&1 | sed -e "s/tool //g")
END_VERSIONS
"""
```

**Benefits:**

- Reduces code duplication
- Easier to maintain
- Clear conditional logic
- Single command structure
- Handles complex conditional scenarios elegantly

#### Approach 2: Separate Script Blocks (Alternative)

For cases with significantly different command structures, use separate blocks:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

if (meta.single_end) {
    """
    tool \\
        --in1 ${reads} \\
        --out1 ${prefix}.output.fq.gz \\
        $args
    """
} else {
    def merge_fastq = save_merged ? "-m --merged_out ${prefix}.merged.fastq.gz" : ''
    """
    tool \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${prefix}_1.output.fq.gz \\
        --out2 ${prefix}_2.output.fq.gz \\
        $merge_fastq \\
        $args
    """
}
```

**Use when:**

- Command structures are fundamentally different
- Post-processing steps differ significantly
- Readability is improved by separation

---

## Template Scripts for Complex Tools

### 1. When to Use Templates

Use template scripts (`.r`, `.py`, `.pl`) when:

- Tool has complex parameter parsing requirements
- Need sophisticated validation or type checking
- Tool requires structured data processing (R/Python)
- Parameter defaults need complex logic

### 2. Template Structure (R Example)

```r
#!/usr/bin/env Rscript

################################################
## Functions                                  ##
################################################

#' Check for Non-Empty, Non-Whitespace String
is_valid_string <- function(input) {
    !is.null(input) && nzchar(trimws(input))
}

#' Parse out options from a string
parse_args <- function(x){
    args_list <- unlist(strsplit(x, ' ?--')[[1]])[-1]
    args_vals <- lapply(args_list, function(x) scan(text=x, what='character', quiet = TRUE))
    args_vals <- lapply(args_vals, function(z){ length(z) <- 2; z})
    parsed_args <- structure(lapply(args_vals, function(x) x[2]), names = lapply(args_vals, function(x) x[1]))
    parsed_args[! is.na(parsed_args)]
}

################################################
## PARSE PARAMETERS FROM NEXTFLOW             ##
################################################

# Set defaults
opt <- list(
    output_prefix = ifelse('$task.ext.prefix' == 'null', '$meta.id', '$task.ext.prefix'),
    threads = '$task.cpus',
    input_file = '$input',
    param1 = 'default_value1',
    param2 = 'default_value2'
)

# Store types for type coercion
opt_types <- lapply(opt, class)

# Parse extra arguments
args_opt <- parse_args('$task.ext.args')

# Apply parameter overrides with type preservation
for (ao in names(args_opt)) {
    if (!ao %in% names(opt)) {
        stop(paste("Invalid option:", ao))
    } else {
        if (!is.null(opt[[ao]])) {
            args_opt[[ao]] <- as(args_opt[[ao]], opt_types[[ao]])
        }
        opt[[ao]] <- args_opt[[ao]]
    }
}

# Validate required parameters
required_opts <- c('output_prefix', 'input_file')
missing <- required_opts[!unlist(lapply(opt[required_opts], is_valid_string)) | !required_opts %in% names(opt)]

if (length(missing) > 0) {
    stop(paste("Missing required options:", paste(missing, collapse=', ')))
}

################################################
## MAIN SCRIPT                               ##
################################################

# Use opt$param1, opt$param2, etc. in your tool calls
```

### 3. Module Integration

```groovy
process COMPLEX_TOOL {
    // ... standard process definition ...

    script:
    template 'tool_script.r'  // or 'tool_script.py', 'tool_script.pl'
}
```

**File Location:**

- Place template in `modules/nf-core/tool/process/templates/`
- Reference as `template 'tool_script.r'` in `main.nf`

### 4. Template Best Practices

- **Parse arguments consistently**: Use a standard `parse_args()` function
- **Preserve types**: Coerce user-provided values to match default types
- **Validate inputs**: Check required parameters and file existence
- **Provide defaults**: Set sensible defaults for all parameters
- **Error handling**: Provide clear error messages for invalid inputs
- **Documentation**: Include function documentation in templates

---

## Conditional Logic

### 1. Input-Dependent Logic

Handle different input types:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Handle different input modes
def reference = "--index $index"
def input_reads = meta.single_end ? 
    "-r ${reads1.join(" ")}" : 
    "-1 ${reads1.join(" ")} -2 ${reads2.join(" ")}"

if (alignment_mode) {
    reference = "-t $transcript_fasta"
    input_reads = "-a $reads"
}
```

### 2. Metadata-Dependent Logic

Use metadata to customize behavior:

```groovy
script:
def args = task.ext.args ?: ''

// Strandedness logic based on metadata
def strandedness_opts = ['A', 'U', 'SF', 'SR', 'IS', 'IU', 'ISF', 'ISR']
def strandedness = 'A'

if (lib_type) {
    if (strandedness_opts.contains(lib_type)) {
        strandedness = lib_type
    } else {
        log.info "[Tool] Invalid library type '${lib_type}', defaulting to auto-detection."
    }
} else {
    strandedness = meta.single_end ? 'U' : 'IU'
    if (meta.strandedness == 'forward') {
        strandedness = meta.single_end ? 'SF' : 'ISF'
    } else if (meta.strandedness == 'reverse') {
        strandedness = meta.single_end ? 'SR' : 'ISR'
    }
}
```

### 3. Resource-Dependent Logic

Adjust parameters based on available resources:

```groovy
script:
// Calculate cores for TrimGalore (leaves cores for other processes)
def cores = 1
if (task.cpus) {
    cores = (task.cpus as int) - 4
    if (meta.single_end) {
        cores = (task.cpus as int) - 3
    }
    if (cores < 1) cores = 1
    if (cores > 8) cores = 8  // TrimGalore max
}
```

---

## Version Tracking

### 1. Standard Version Output

Always generate `versions.yml`:

```groovy
script:
"""
tool $args input_file

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool_name: \$(tool --version 2>&1 | sed -e "s/tool //g")
    dependency1: \$(dependency1 --version 2>&1 | sed 's/^.*version //; s/ .*\$//')
END_VERSIONS
"""
```

### 2. Version Extraction Patterns

Common patterns for extracting versions:

```bash
# Simple version
tool --version

# Extract from verbose output
tool --version 2>&1 | sed -e "s/tool //g"

# Extract from multi-line output
echo $(tool --version 2>&1) | sed 's/^.*version //; s/ .*$//'

# R package version
Rscript -e "cat(as.character(packageVersion('package_name')))"

# Python package version
python -c "import package; print(package.__version__)"
```

### 3. Multiple Tool Versions

Track all tools used in the module:

```groovy
script:
"""
tool1 $args1 input1
tool2 $args2 input2

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool1: \$(tool1 --version 2>&1 | sed -e "s/tool1 //g")
    tool2: \$(tool2 --version 2>&1 | sed -e "s/tool2 //g")
    samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
END_VERSIONS
"""
```

---

## Stub Implementation

### 1. Purpose

Stubs are used for:

- Testing pipeline structure without running tools
- Validating output channel definitions
- Fast iteration during development

### 2. Basic Stub

```groovy
stub:
def prefix = task.ext.prefix ?: "${meta.id}"
"""
touch ${prefix}.output.bam
touch ${prefix}.log

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool_name: "stub_version"
END_VERSIONS
"""
```

### 3. Conditional Stub

Match the script's conditional logic:

```groovy
stub:
def prefix = task.ext.prefix ?: "${meta.id}"
def is_single_output = meta.single_end || task.ext.args?.contains('--interleaved_in')
def touch_reads = is_single_output ? 
    "echo '' | gzip > ${prefix}.output.fq.gz" : 
    "echo '' | gzip > ${prefix}_1.output.fq.gz ; echo '' | gzip > ${prefix}_2.output.fq.gz"

"""
$touch_reads
touch ${prefix}.json
touch ${prefix}.html

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool_name: "stub_version"
END_VERSIONS
"""
```

### 4. Stub Best Practices

- **Match outputs**: Create all expected output files
- **Match structure**: Use same conditional logic as script
- **Version tracking**: Include versions.yml with stub version
- **Empty files**: Use `touch` or `echo '' | gzip` for empty files
- **Directories**: Create directories if needed: `mkdir -p dir/subdir`

---

## Error Handling and Validation

### 1. Profile Compatibility Checks

For tools that require specific container engines (Docker/Singularity) and are not available in conda/mamba, add validation checks:

**In Module Script Block:**

```groovy
script:
// Check if tool is compatible with current profile
if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
    error "MODULE_NAME does not support Conda/Mamba. Please use Docker/Singularity/Podman instead."
}

def args = task.ext.args ?: ''
// ... rest of script
```

**In Workflow Validation Section:**

For tools that are critical and used by the workflow, add checks at the workflow level:

```groovy
workflow MAIN_WORKFLOW {
    main:
    
    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        VALIDATE PROFILE COMPATIBILITY
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    
    // Check for tools that require Docker and are not available in conda/mamba
    if ((workflow.profile.contains('conda') || workflow.profile.contains('mamba')) && !params.skip_tool) {
        def separator = "=".multiply(80)
        log.error(separator)
        log.error("ERROR: TOOL_NAME is not available in conda/mamba!")
        log.error(separator)
        log.error("")
        log.error("The TOOL_NAME tool requires a custom Docker image and cannot")
        log.error("be used with the conda/mamba profile. TOOL_NAME is not available in")
        log.error("bioconda or biocontainers.")
        log.error("")
        log.error("Solutions:")
        log.error("  1. Use Docker profile:     -profile docker")
        log.error("  2. Use Singularity profile: -profile singularity")
        log.error("  3. Use Podman profile:      -profile podman")
        log.error("  4. Skip tool analysis:     --skip_tool")
        log.error("")
        log.error("For more information, see:")
        log.error("  - docs/usage.md (Tool Custom Docker Image section)")
        log.error("  - modules/nf-core/tool/README.md")
        log.error("")
        log.error(separator)
        exit(1, "TOOL_NAME cannot be used with conda/mamba profile. Use Docker/Singularity/Podman or skip with --skip_tool")
    }
    
    // ... rest of workflow
}
```

**When to Use Each Approach:**

- **Module-level check**: Use when the tool is always incompatible with conda/mamba
- **Workflow-level check**: Use when:
  - The tool is optional (can be skipped with a parameter)
  - You want to provide detailed error messages with solutions
  - The check needs to run before any processing starts
  - Multiple modules share the same incompatibility

**Best Practices:**

- Fail early: Check at workflow start, not during execution
- Provide clear error messages: Explain why and how to fix
- Offer solutions: List alternative profiles or skip options
- Reference documentation: Point users to relevant docs
- Use descriptive separators: Make error messages stand out

### 2. Input Validation

Validate inputs before processing:

```groovy
script:
def args = task.ext.args ?: ''

// Validate required parameters
def prob_exists = args =~ /-p|--probability/
def nrec_exists = args =~ /-n|--record-count/
if (!(prob_exists || nrec_exists)) {
    error "MODULE requires --probability (-p) or --record-count (-n) specified in task.ext.args!"
}

// Validate file inputs
def n_fastq = fastq instanceof List ? fastq.size() : 1
if (n_fastq > 2) {
    error "MODULE only accepts 1 or 2 FASTQ files!"
}
```

### 3. Argument Validation

Check for conflicting or invalid arguments:

```groovy
script:
def args = task.ext.args ?: ''

// Remove incompatible arguments for single-end
if (meta.single_end) {
    def args_list = args.split("\\s(?=--)").toList()
    args_list.removeAll { arg -> arg.toLowerCase().contains('_r2 ') }
    args = args_list.join(' ')
}
```

### 4. File Existence Checks

Verify files exist before use:

```bash
# In bash script
if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found!" >&2
    exit 1
fi
```

---

## Resource Management

### 1. CPU Usage

Always use `$task.cpus` for thread/CPU parameters:

```groovy
script:
"""
tool \\
    --threads $task.cpus \\
    $args \\
    input_file
"""
```

### 2. Memory Usage

Reference memory when needed (usually handled by Nextflow):

```groovy
script:
"""
tool \\
    --memory ${task.memory.toGiga()}G \\
    --threads $task.cpus \\
    $args \\
    input_file
"""
```

### 3. Temporary Directories

Use Nextflow's temp directory:

```groovy
script:
"""
tool \\
    --tmp-dir ${workDir}/tmp \\
    --threads $task.cpus \\
    $args \\
    input_file
"""
```

---

## Documentation

### 1. Inline Comments

Document complex logic:

```groovy
script:
def args = task.ext.args ?: ''

// Calculate number of --cores for TrimGalore based on value of task.cpus
// See: https://github.com/FelixKrueger/TrimGalore/blob/master/CHANGELOG.md#version-060
// Leaves 3-4 cores for other processes (FastQC, etc.)
def cores = 1
if (task.cpus) {
    cores = (task.cpus as int) - 4
    // ...
}
```

### 2. Parameter Documentation

Document expected parameter formats:

```groovy
script:
/* args requires:
    --probability <f64>: Probability read is kept, between 0 and 1. Mutually exclusive with record-count.
    --record-count <u64>: Number of records to keep. Mutually exclusive with probability
*/
def args = task.ext.args ?: ''
```

### 3. File Pattern Documentation

Document output file patterns:

```groovy
output:
// Main output: BAM file with alignments
tuple val(meta), path("*.bam"), emit: bam
// Log file: Contains alignment statistics
tuple val(meta), path("*.log"), emit: log
// Optional: Unmapped reads if --outReadsUnmapped Fastx is specified
tuple val(meta), path("*.fastq.gz"), emit: fastq, optional: true
```

---

## Example Templates

### 1. Simple Command-Line Tool

```groovy
process SIMPLE_TOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version--build' :
        'biocontainers/tool:version--build' }"

    input:
    tuple val(meta), path(input_file)

    output:
    tuple val(meta), path("*.output"), emit: output
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    tool \\
        --input $input_file \\
        --output ${prefix}.output \\
        --threads $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: \$(tool --version 2>&1 | sed -e "s/tool //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: "stub_version"
    END_VERSIONS
    """
}
```

### 2. Complex Tool with Many Parameters

```groovy
process COMPLEX_TOOL {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version--build' :
        'biocontainers/tool:version--build' }"

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(index)
    tuple val(meta3), path(annotation)
    val flag1
    val flag2

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.log"), emit: log
    tuple val(meta), path("*.json"), emit: json, optional: true
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    // Build default arguments
    def default_args = [
        '--param1 value1',
        '--param2 value2',
        flag1 ? '--flag1' : '',
        flag2 ? '--flag2 value' : '',
        params.conditional_param ? '--conditional' : ''
    ]

    // Split user-provided args
    def user_args = args ? args.split("\\s(?=--)") : []

    // Combine arguments
    def all_args = (default_args + user_args)
        .flatten()
        .unique(false)
        .findAll { it != '' }
        .join(' ')

    // Handle single-end vs paired-end
    def reads1 = []
    def reads2 = []
    meta.single_end ? 
        [reads].flatten().each{ item -> reads1 << item } : 
        reads.eachWithIndex{ v, ix -> ( ix & 1 ? reads2 : reads1) << v }

    def input_reads = meta.single_end ? 
        "-r ${reads1.join(",")}" : 
        "-1 ${reads1.join(",")} -2 ${reads2.join(",")}"

    """
    tool \\
        --index $index \\
        --annotation $annotation \\
        --readFilesIn $input_reads \\
        --runThreadN $task.cpus \\
        --outFileNamePrefix ${prefix}. \\
        $all_args

    # Post-processing
    if [ -f ${prefix}.Unmapped.out.mate1 ]; then
        mv ${prefix}.Unmapped.out.mate1 ${prefix}.unmapped_1.fastq
        gzip ${prefix}.unmapped_1.fastq
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: \$(tool --version 2>&1 | sed -e "s/tool //g")
        dependency: \$(dependency --version 2>&1 | sed 's/^.*version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam
    touch ${prefix}.log
    touch ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: "stub_version"
    END_VERSIONS
    """
}
```

### 3. Template-Based Tool (R/Python)

```groovy
process TEMPLATE_TOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version--build' :
        'biocontainers/tool:version--build' }"

    input:
    tuple val(meta), path(input_file)
    tuple val(meta2), path(annotation)
    val param1
    val param2

    output:
    tuple val(meta), path("*.results.tsv"), emit: results
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    template 'tool_script.r'  // or 'tool_script.py'

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.results.tsv
    touch ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: "stub_version"
    END_VERSIONS
    """
}
```

---

## Summary Checklist

When writing or reviewing a module `main.nf`:

- [ ] Process name follows nf-core conventions (UPPER_SNAKE_CASE)
- [ ] Appropriate label set (`process_single`, `process_low`, `process_medium`, `process_high`)
- [ ] Container and conda environment specified
- [ ] Input channels use tuples with `meta` as first element
- [ ] Output channels use descriptive names and mark optional outputs
- [ ] Mutually exclusive inputs/outputs validated and handled correctly
- [ ] Optional inputs that affect behavior handled conditionally
- [ ] `task.ext.args` used for parameter flexibility
- [ ] Default arguments provided when needed
- [ ] User arguments can override defaults
- [ ] Conditional logic handles different input types (single-end/paired-end)
- [ ] Version tracking implemented (`versions.yml`)
- [ ] Stub implementation matches script structure
- [ ] Resource usage (`task.cpus`, `task.memory`) properly referenced
- [ ] Error handling for invalid inputs/arguments
- [ ] Profile compatibility checks for tools requiring specific container engines
- [ ] Inline comments explain complex logic
- [ ] Template scripts used for complex parameter parsing (if needed)
- [ ] Post-processing handles file renaming/compression
- [ ] All outputs properly defined and emitted

---

## References

- [Nextflow Process Documentation](https://www.nextflow.io/docs/latest/process.html)
- [nf-core Module Guidelines](https://nf-co.re/docs/contributing/modules)
- [nf-core Module Test Guidelines](https://nf-co.re/docs/contributing/modules_testing)
- Current pipeline modules: `modules/nf-core/*/main.nf`
