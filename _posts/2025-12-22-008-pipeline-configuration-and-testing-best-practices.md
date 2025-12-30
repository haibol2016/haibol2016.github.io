---
layout: post
title: "Best Practices for Nextflow Configuration and Testing"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, configuration, testing, bioinformatics, workflows, best-practices, hpc, aws]
author: Haibo Liu, PhD
---


This document outlines best practices for creating and managing Nextflow configuration files, including `nextflow_schema.json`, `modules.json`, `nextflow.config`, HPC cluster configurations, AWS Batch configurations, parameter files, and testing strategies.


## Creating nextflow_schema.json

### 1. File Structure

The `nextflow_schema.json` file defines all pipeline parameters in JSON Schema format:

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://raw.githubusercontent.com/nf-core/pipeline/master/nextflow_schema.json",
    "title": "nf-core/pipeline pipeline parameters",
    "description": "Brief description of the pipeline",
    "type": "object",
    "$defs": {
        "input_output_options": {
            "title": "Input/output options",
            "type": "object",
            "fa_icon": "fas fa-terminal",
            "description": "Define where the pipeline should find input data and save output data.",
            "required": ["input", "outdir"],
            "properties": {
                "input": {
                    "type": "string",
                    "format": "file-path",
                    "exists": true,
                    "schema": "assets/schema_input.json",
                    "pattern": "^\\S+\\.(csv|tsv|json|yaml|yml)$",
                    "description": "Path to input samplesheet file.",
                    "help_text": "Detailed help text explaining the parameter.",
                    "fa_icon": "fas fa-file-csv"
                }
            }
        }
    },
    "allOf": [
        { "$ref": "#/$defs/input_output_options" },
        { "$ref": "#/$defs/reference_genome_options" }
    ]
}
```

### 2. Parameter Organization

Organize parameters into logical groups using `$defs`:

```json
"$defs": {
    "input_output_options": { ... },
    "reference_genome_options": { ... },
    "read_trimming_options": { ... },
    "alignment_options": { ... },
    "analysis_options": { ... }
}
```

**Best Practices:**
- Group related parameters together
- Use descriptive group titles
- Include Font Awesome icons (`fa_icon`)
- Add clear descriptions

### 3. Parameter Properties

Each parameter should include:

```json
{
    "parameter_name": {
        "type": "string",           // string, integer, number, boolean, array, object
        "format": "file-path",      // file-path, directory-path, uri, email, etc.
        "exists": true,             // For file paths
        "pattern": "^\\S+\\.csv$", // Regex pattern for validation
        "default": "value",         // Default value (optional)
        "description": "Brief description",
        "help_text": "Detailed help text with examples",
        "fa_icon": "fas fa-icon",
        "enum": ["option1", "option2"],  // For restricted choices
        "minimum": 0,               // For numeric types
        "maximum": 100
    }
}
```

### 4. Parameter Types

**String:**
```json
{
    "input": {
        "type": "string",
        "format": "file-path",
        "exists": true,
        "description": "Input file path"
    }
}
```

**Integer:**
```json
{
    "min_read_length": {
        "type": "integer",
        "default": 25,
        "minimum": 1,
        "maximum": 1000,
        "description": "Minimum read length"
    }
}
```

**Boolean:**
```json
{
    "skip_trimming": {
        "type": "boolean",
        "description": "Skip read trimming step"
        // Note: Don't include "default": false for booleans (redundant)
    }
}
```

**Enum (Restricted Choices):**
```json
{
    "trimmer": {
        "type": "string",
        "default": "trimgalore",
        "enum": ["trimgalore", "fastp"],
        "description": "Tool to use for read trimming"
    }
}
```

### 5. Required Parameters

Mark required parameters in the group definition:

```json
{
    "input_output_options": {
        "required": ["input", "outdir"],
        "properties": { ... }
    }
}
```

### 6. Conditional Requirements

Use `help_text` to document conditional requirements:

```json
{
    "gff": {
        "type": "string",
        "format": "file-path",
        "description": "Path to GFF3 annotation file.",
        "help_text": "This parameter must be specified if neither --genome nor --gtf are specified."
    }
}
```

### 7. Default Values

Set defaults appropriately:

```json
{
    "min_read_length": {
        "type": "integer",
        "default": 25  // Explicit default
    },
    "transcript_fasta": {
        "type": "string",
        "default": null  // Explicit null for optional parameters
    },
    "skip_trimming": {
        "type": "boolean"
        // No default for boolean (defaults to false)
    }
}
```

### 8. Validation Patterns

Use regex patterns for validation:

```json
{
    "input": {
        "pattern": "^\\S+\\.(csv|tsv|json|yaml|yml)$"
    },
    "email": {
        "pattern": "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$"
    }
}
```

### 9. Schema References

Reference external schemas for complex validation:

```json
{
    "input": {
        "schema": "assets/schema_input.json",
        "description": "Input samplesheet validated against schema"
    }
}
```

### 10. Best Practices Summary

- [ ] Organize parameters into logical groups
- [ ] Use descriptive titles and descriptions
- [ ] Include helpful `help_text` with examples
- [ ] Mark required parameters
- [ ] Use appropriate types and formats
- [ ] Set sensible defaults
- [ ] Use validation patterns where appropriate
- [ ] Document conditional requirements
- [ ] Include Font Awesome icons for UI
- [ ] Avoid redundant `default: false` for booleans

---

## Creating modules.json

### 1. File Structure

The `modules.json` file tracks installed modules and subworkflows from nf-core/modules:

```json
{
    "name": "nf-core/pipeline",
    "homePage": "https://github.com/nf-core/pipeline",
    "repos": {
        "https://github.com/nf-core/modules.git": {
            "modules": {
                "nf-core": {
                    "module_name/submodule": {
                        "branch": "master",
                        "git_sha": "abc123def456...",
                        "installed_by": ["subworkflow_name", "modules"]
                    }
                }
            },
            "subworkflows": {
                "nf-core": {
                    "subworkflow_name": {
                        "branch": "master",
                        "git_sha": "abc123def456...",
                        "installed_by": ["subworkflows"]
                    }
                }
            }
        }
    }
}
```

### 2. Module Entries

Each module entry includes:

```json
{
    "fastqc": {
        "branch": "master",
        "git_sha": "41dfa3f7c0ffabb96a6a813fe321c6d1cc5b6e46",
        "installed_by": ["fastq_fastqc_umitools_fastp", "fastq_fastqc_umitools_trimgalore", "modules"]
    }
}
```

**Fields:**
- `branch`: Git branch name (usually "master")
- `git_sha`: Full commit SHA of the module version
- `installed_by`: List of subworkflows/modules that use this module

### 3. Subworkflow Entries

Subworkflow entries follow the same structure:

```json
{
    "fastq_qc_trim_filter_setstrandedness": {
        "branch": "master",
        "git_sha": "d9ec4ef289ad39b8a662a7a12be50409b11df84b",
        "installed_by": ["subworkflows"]
    }
}
```

### 4. Tools for Managing modules.json

The `modules.json` file should be managed using nf-core CLI tools. Here are the available commands:

#### Module Management Commands

**Install a module:**
```bash
nf-core modules install <module_name>
# Example: nf-core modules install fastqc
```

**Install multiple modules:**
```bash
nf-core modules install fastqc trimgalore samtools
```

**Install a module from a specific path:**
```bash
nf-core modules install <module_name> --dir modules/nf-core
```

**Update a specific module:**
```bash
nf-core modules update <module_name>
# Example: nf-core modules update fastqc
```

**Update all modules:**
```bash
nf-core modules update --all
```

**Update modules to latest versions:**
```bash
nf-core modules update --all --latest
```

**Remove a module:**
```bash
nf-core modules remove <module_name>
# Example: nf-core modules remove fastqc
```

**List installed modules:**
```bash
nf-core modules list
```

**Check module versions:**
```bash
nf-core modules list --check-versions
```

**Show module information:**
```bash
nf-core modules info <module_name>
# Example: nf-core modules info fastqc
```

#### Subworkflow Management Commands

**Install a subworkflow:**
```bash
nf-core subworkflows install <subworkflow_name>
# Example: nf-core subworkflows install fastq_qc_trim_filter_setstrandedness
```

**Update a subworkflow:**
```bash
nf-core subworkflows update <subworkflow_name>
```

**Update all subworkflows:**
```bash
nf-core subworkflows update --all
```

**List installed subworkflows:**
```bash
nf-core subworkflows list
```

**Remove a subworkflow:**
```bash
nf-core subworkflows remove <subworkflow_name>
```

#### Additional Tools

**Create modules.json from scratch:**
```bash
nf-core modules create-test-yml
```

**Lint modules.json:**
```bash
nf-core modules lint
```

**Check for module updates:**
```bash
nf-core modules check-versions
```

**Install nf-core CLI:**
```bash
# Using pip
pip install nf-core

# Using conda
conda install -c bioconda nf-core

# Using mamba
mamba install -c bioconda nf-core
```

### 5. Maintenance

**When to update:**
- After installing new modules: `nf-core modules install <module_name>`
- After updating modules: `nf-core modules update <module_name>` or `--all`
- After adding new subworkflows: `nf-core subworkflows install <subworkflow_name>`
- After module version changes: `nf-core modules update --all`
- When checking for updates: `nf-core modules check-versions`

**Best Practices:**
- **Don't manually edit `modules.json`** - Always use nf-core CLI tools
- Commit `modules.json` to version control after changes
- Review `installed_by` fields to understand dependencies
- Keep git SHAs accurate for reproducibility
- Use `nf-core modules check-versions` regularly to find updates
- Test after updating modules to ensure compatibility
- Document why specific module versions are pinned (if needed)

### 6. Module Installation Examples

```bash
# Install a single module
nf-core modules install fastqc

# Install multiple modules at once
nf-core modules install fastqc trimgalore samtools

# Install a module and update modules.json
nf-core modules install star/align

# Update all modules to latest versions
nf-core modules update --all --latest

# Update a specific module
nf-core modules update fastqc

# Check which modules have updates available
nf-core modules check-versions

# List all installed modules
nf-core modules list

# Install a subworkflow
nf-core subworkflows install fastq_qc_trim_filter_setstrandedness

# Update all subworkflows
nf-core subworkflows update --all
```

---

## Creating nextflow.config

### 1. File Structure

Organize `nextflow.config` in clear sections:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Pipeline Name Nextflow config file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Default config options for all compute environments
----------------------------------------------------------------------------------------
*/

// Global default params
params {
    // Parameter definitions
}

// Load base.config by default
includeConfig 'conf/base.config'

// Profiles
profiles {
    docker { ... }
    singularity { ... }
    test { includeConfig 'conf/test.config' }
}

// Load custom configs
includeConfig params.custom_config_base ? "${params.custom_config_base}/nfcore_custom.config" : "/dev/null"

// Load igenomes.config if required
includeConfig !params.igenomes_ignore ? 'conf/igenomes.config' : 'conf/igenomes_ignored.config'

// Environment variables
env {
    PYTHONNOUSERSITE = 1
    R_PROFILE_USER   = "/.Rprofile"
    R_ENVIRON_USER   = "/.Renviron"
    JULIA_DEPOT_PATH = "/usr/local/share/julia"
}

// Process shell options
process.shell = [
    "bash",
    "-C",      // No clobber
    "-e",      // Exit on error
    "-u",      // Unset variables error
    "-o",
    "pipefail" // Pipe failure handling
]

// Timeline, report, trace, DAG
timeline { enabled = true; file = "${params.outdir}/pipeline_info/execution_timeline.html" }
report { enabled = true; file = "${params.outdir}/pipeline_info/execution_report.html" }
trace { enabled = true; file = "${params.outdir}/pipeline_info/execution_trace.txt" }
dag { enabled = true; file = "${params.outdir}/pipeline_info/pipeline_dag.html" }

// Manifest
manifest {
    name            = 'nf-core/pipeline'
    homePage        = 'https://github.com/nf-core/pipeline'
    description     = "Pipeline description"
    mainScript      = 'main.nf'
    defaultBranch   = 'master'
    nextflowVersion = '!>=25.04.8'
    version         = '1.0.0'
}

// Plugins
plugins {
    id 'nf-schema@2.5.1'
}

// Validation
validation {
    defaultIgnoreParams = ["genomes"]
    monochromeLogs = params.monochrome_logs
}

// Load modules.config
includeConfig 'conf/modules.config'
```

### 2. Parameter Definitions

Define all parameters with defaults:

```groovy
params {
    // Input options
    input      = null
    contrasts  = null
    outdir     = null

    // Reference genome
    genome     = null
    fasta      = null
    gtf        = null
    gff        = null

    // Analysis options
    skip_trimming = false
    skip_alignment = false
    trimmer = 'trimgalore'

    // Tool-specific options
    extra_star_align_args = null
    extra_fastqc_args = null

    // Boilerplate
    email = null
    help = false
    version = false
}
```

**Best Practices:**
- Group related parameters
- Use descriptive names
- Set appropriate defaults
- Use `null` for optional parameters
- Document complex parameters

### 3. Profiles

Define profiles for different execution environments:

```groovy
profiles {
    docker {
        docker.enabled = true
        conda.enabled = false
        singularity.enabled = false
        docker.runOptions = '-u $(id -u):$(id -g)'
    }
    
    // Docker with AMD64 emulation (for macOS ARM64)
    docker_amd64 {
        docker.enabled = true
        docker.runOptions = '-u $(id -u):$(id -g) --platform=linux/amd64'
        conda.enabled = false
        singularity.enabled = false
    }
    
    singularity {
        singularity.enabled = true
        singularity.autoMounts = true
        singularity.cacheDir = "${workDir}/singularity"
        conda.enabled = false
        docker.enabled = false
    }
    
    conda {
        conda.enabled = true
        conda.channels = ['conda-forge', 'bioconda']
        conda.cacheDir = "${workDir}/conda"
        docker.enabled = false
        singularity.enabled = false
    }
    
    mamba {
        conda.enabled = true
        conda.useMamba = true
        conda.cacheDir = "${workDir}/mamba"
        docker.enabled = false
        singularity.enabled = false
    }
    
    // ARM64 profile with Wave (for automatic container conversion)
    arm64 {
        process.arch = 'arm64'
        apptainer.ociAutoPull = true
        singularity.ociAutoPull = true
        wave.enabled = true
        wave.freeze = true
        wave.strategy = 'conda,container'
    }
    
    test {
        includeConfig 'conf/test.config'
    }
    
    test_full {
        includeConfig 'conf/test_full.config'
    }
    
    debug {
        dumpHashes = true
        process.beforeScript = 'echo $HOSTNAME'
        cleanup = false
    }
    
    gpu {
        docker.runOptions = '-u $(id -u):$(id -g) --gpus all'
        apptainer.runOptions = '--nv'
        singularity.runOptions = '--nv'
    }
}
```

**Profile Selection Guidelines:**

- **Docker**: Use for local development, CI/CD, and production (when Docker is available)
- **Docker with AMD64 emulation** (`docker_amd64`): Use on macOS ARM64 for compatibility with AMD64-only images
- **Singularity/Apptainer**: Use on HPC clusters where Docker is not available
- **Conda/Mamba**: Use when containers are unavailable or for development (slower but more flexible)
- **ARM64 profile**: Use on ARM64 systems with Wave for automatic platform handling

**Note:** Some tools may not be available in all environments. For example, RibORF 2.0 requires a custom Docker image and is not available via conda/mamba. See [Container Management Best Practices](CONTAINER_MANAGEMENT_BEST_PRACTICES.md) for detailed guidance.

### 4. Container Registry Configuration

Set default registries:

```groovy
apptainer.registry    = 'quay.io'
docker.registry       = 'quay.io'
podman.registry       = 'quay.io'
singularity.registry  = 'quay.io'
charliecloud.registry = 'quay.io'
```

**Best Practices:**
- Use `quay.io/biocontainers/` prefix for biocontainers images
- Verify image availability before committing to pipeline
- Document custom Docker images (e.g., RibORF 2.0)
- Check platform compatibility (AMD64 vs ARM64)

**For detailed container management guidance, see:**
- [Container Management Best Practices](CONTAINER_MANAGEMENT_BEST_PRACTICES.md) - Comprehensive guide on conda/mamba environments, Docker, Singularity, and cross-platform considerations

### 5. Environment Variables

Export variables to prevent conflicts:

```groovy
env {
    PYTHONNOUSERSITE = 1
    R_PROFILE_USER   = "/.Rprofile"
    R_ENVIRON_USER   = "/.Renviron"
    JULIA_DEPOT_PATH = "/usr/local/share/julia"
}
```

### 6. Process Shell Options

Configure safe shell behavior:

```groovy
process.shell = [
    "bash",
    "-C",      // No clobber - prevent overwriting files
    "-e",      // Exit on error
    "-u",      // Unset variables error
    "-o",
    "pipefail" // Return error if any command in pipe fails
]
```

### 7. Manifest

Define pipeline metadata:

```groovy
manifest {
    name            = 'nf-core/pipeline'
    homePage        = 'https://github.com/nf-core/pipeline'
    description     = "Pipeline description"
    mainScript      = 'main.nf'
    defaultBranch   = 'master'
    nextflowVersion = '!>=25.04.8'
    version         = '1.0.0'
    doi             = 'https://doi.org/10.5281/zenodo.xxxxx'
    contributors    = [
        [
            name: 'Author Name',
            affiliation: 'Institution',
            email: 'email@example.com',
            github: '@username',
            contribution: ['author'],
            orcid: '0000-0000-0000-0000'
        ]
    ]
}
```

### 8. Best Practices Summary

- [ ] Clear section headers with separators
- [ ] All parameters defined with defaults
- [ ] Profiles for all execution environments
- [ ] Environment variables to prevent conflicts
- [ ] Safe shell options configured
- [ ] Manifest with complete metadata
- [ ] Plugins properly configured
- [ ] Validation settings appropriate
- [ ] Include configs in logical order

---

## HPC Cluster Configurations

### 1. SLURM Configuration

Create `conf/slurm.config`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SLURM cluster configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    executor = 'slurm'
    queue    = 'normal'
    clusterOptions = '-A myaccount'
    
    // Default resource limits
    cpus   = { 1      * task.attempt }
    memory = { 6.GB   * task.attempt }
    time   = { 4.h    * task.attempt }
    
    // Process-specific resources
    withLabel:process_single {
        cpus   = { 1 }
        memory = { 6.GB * task.attempt }
        time   = { 4.h  * task.attempt }
    }
    
    withLabel:process_low {
        cpus   = { 2     * task.attempt }
        memory = { 12.GB * task.attempt }
        time   = { 4.h   * task.attempt }
    }
    
    withLabel:process_medium {
        cpus   = { 6     * task.attempt }
        memory = { 36.GB * task.attempt }
        time   = { 8.h   * task.attempt }
    }
    
    withLabel:process_high {
        cpus   = { 12    * task.attempt }
        memory = { 72.GB * task.attempt }
        time   = { 16.h  * task.attempt }
    }
    
    withLabel:process_long {
        time = { 48.h * task.attempt }
    }
    
    withLabel:process_high_memory {
        memory = { 200.GB * task.attempt }
    }
}

executor {
    name = 'slurm'
    queueSize = 100
    pollInterval = '30 sec'
    submitRateLimit = '10/1min'
}
```

**Key SLURM Options:**
- `executor = 'slurm'`: Use SLURM executor
- `queue`: Default queue name
- `clusterOptions`: Additional SLURM options (e.g., account, partition)
- `queueSize`: Maximum concurrent jobs
- `pollInterval`: How often to check job status
- `submitRateLimit`: Rate limit for job submission

### 2. SGE (Sun Grid Engine) Configuration

Create `conf/sge.config`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SGE cluster configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    executor = 'sge'
    queue    = 'all.q'
    clusterOptions = '-l h_vmem=6G'
    
    cpus   = { 1      * task.attempt }
    memory = { 6.GB   * task.attempt }
    time   = { 4.h    * task.attempt }
    
    withLabel:process_single {
        cpus   = { 1 }
        memory = { 6.GB * task.attempt }
        time   = { 4.h  * task.attempt }
    }
    
    withLabel:process_medium {
        cpus   = { 6     * task.attempt }
        memory = { 36.GB * task.attempt }
        time   = { 8.h   * task.attempt }
    }
    
    withLabel:process_high {
        cpus   = { 12    * task.attempt }
        memory = { 72.GB * task.attempt }
        time   = { 16.h  * task.attempt }
    }
}

executor {
    name = 'sge'
    queueSize = 100
    pollInterval = '30 sec'
}
```

### 3. PBS/Torque Configuration

Create `conf/pbs.config`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PBS/Torque cluster configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    executor = 'pbs'
    queue    = 'batch'
    clusterOptions = '-l walltime=4:00:00'
    
    cpus   = { 1      * task.attempt }
    memory = { 6.GB   * task.attempt }
    time   = { 4.h    * task.attempt }
    
    withLabel:process_single {
        cpus   = { 1 }
        memory = { 6.GB * task.attempt }
        time   = { 4.h  * task.attempt }
    }
    
    withLabel:process_medium {
        cpus   = { 6     * task.attempt }
        memory = { 36.GB * task.attempt }
        time   = { 8.h   * task.attempt }
    }
}

executor {
    name = 'pbs'
    queueSize = 100
    pollInterval = '30 sec'
}
```

### 4. LSF Configuration

Create `conf/lsf.config`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LSF cluster configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    executor = 'lsf'
    queue    = 'normal'
    clusterOptions = '-M 6000 -R "rusage[mem=6000]"'
    
    cpus   = { 1      * task.attempt }
    memory = { 6.GB   * task.attempt }
    time   = { 4.h    * task.attempt }
    
    withLabel:process_single {
        cpus   = { 1 }
        memory = { 6.GB * task.attempt }
        time   = { 4.h  * task.attempt }
    }
}

executor {
    name = 'lsf'
    queueSize = 100
    pollInterval = '30 sec'
}
```

### 5. HPC Best Practices

1. **Resource Allocation:**
   - Match resources to process labels
   - Use `task.attempt` for retry scaling
   - Set appropriate time limits

2. **Queue Management:**
   - Use appropriate queue names
   - Set `queueSize` to limit concurrent jobs
   - Configure `submitRateLimit` to avoid overwhelming scheduler

3. **Cluster-Specific Options:**
   - Use `clusterOptions` for account, partition, etc.
   - Test resource requests match cluster limits
   - Document cluster-specific requirements

4. **Container Support:**
   - Ensure Singularity/Apptainer is available
   - Configure container paths if needed
   - Test container execution

5. **Storage Considerations:**
   - Use shared filesystems for work directory
   - Configure scratch space if available
   - Set appropriate `workDir` location

---

## AWS Batch Configurations

### 1. Basic AWS Batch Configuration

Create `conf/awsbatch.config`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    AWS Batch configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process {
    executor = 'awsbatch'
    queue    = 'my-batch-queue'
    
    cpus   = { 1      * task.attempt }
    memory = { 6.GB   * task.attempt }
    time   = { 4.h    * task.attempt }
    
    withLabel:process_single {
        cpus   = { 1 }
        memory = { 6.GB * task.attempt }
        time   = { 4.h  * task.attempt }
    }
    
    withLabel:process_medium {
        cpus   = { 6     * task.attempt }
        memory = { 36.GB * task.attempt }
        time   = { 8.h   * task.attempt }
    }
    
    withLabel:process_high {
        cpus   = { 12    * task.attempt }
        memory = { 72.GB * task.attempt }
        time   = { 16.h  * task.attempt }
    }
}

aws {
    region = 'us-east-1'
    batch {
        cliPath = '/home/ec2-user/miniconda3/envs/nextflow/bin/aws'
        maxParallelTransfers = 4
    }
}

executor {
    name = 'awsbatch'
    queueSize = 100
    pollInterval = '30 sec'
}
```

### 2. AWS Batch with S3 Storage

```groovy
process {
    executor = 'awsbatch'
    queue    = 'my-batch-queue'
    
    // Use S3 for work directory
    scratch = false
}

aws {
    region = 'us-east-1'
    batch {
        cliPath = '/home/ec2-user/miniconda3/envs/nextflow/bin/aws'
    }
    
    // S3 configuration
    s3 {
        storageClass = 'STANDARD'
        storageEncryption = 'AES256'
        maxParallelTransfers = 4
        maxTransferAttempts = 6
    }
}

// Use S3 for work directory
workDir = 's3://my-bucket/work'

// Use S3 for output
params.outdir = 's3://my-bucket/results'
```

### 3. AWS Batch with EFS

```groovy
process {
    executor = 'awsbatch'
    queue    = 'my-batch-queue'
    
    // Use EFS for work directory (faster than S3)
    scratch = '/mnt/efs/work'
}

aws {
    region = 'us-east-1'
    batch {
        cliPath = '/home/ec2-user/miniconda3/envs/nextflow/bin/aws'
    }
}

// Use EFS for work directory
workDir = '/mnt/efs/work'

// Use S3 for output
params.outdir = 's3://my-bucket/results'
```

### 4. AWS Batch Job Definition Mapping

Map process labels to AWS Batch job definitions:

```groovy
process {
    executor = 'awsbatch'
    
    withLabel:process_single {
        executor.queue = 'single-queue'
        executor.jobRole = 'arn:aws:iam::account:role/BatchJobRole'
    }
    
    withLabel:process_high {
        executor.queue = 'high-memory-queue'
        executor.jobRole = 'arn:aws:iam::account:role/BatchJobRole'
    }
}

aws {
    region = 'us-east-1'
    batch {
        cliPath = '/home/ec2-user/miniconda3/envs/nextflow/bin/aws'
    }
}
```

### 5. AWS Batch Best Practices

1. **Queue Configuration:**
   - Create separate queues for different resource needs
   - Use compute environments with appropriate instance types
   - Configure job definitions with correct resources

2. **Storage Strategy:**
   - Use EFS for work directory (faster I/O)
   - Use S3 for final outputs (cost-effective)
   - Configure appropriate storage classes

3. **IAM Roles:**
   - Use IAM roles for Batch jobs (not access keys)
   - Grant minimal required permissions
   - Use separate roles for different job types

4. **Container Images:**
   - Push container images to ECR
   - Use appropriate image tags
   - Test container execution in Batch

5. **Cost Optimization:**
   - Use Spot instances where possible
   - Right-size compute resources
   - Clean up work directories regularly
   - Use appropriate S3 storage classes

6. **Monitoring:**
   - Enable CloudWatch logging
   - Monitor Batch queue metrics
   - Set up alerts for failures

---

## Creating Parameter Files

### 1. Using nf-core launch (Interactive Web Interface)

Launch an interactive web interface to configure parameters:

```bash
nf-core launch nf-core/pipeline
```

**Features:**
- Opens a web browser with an interactive parameter configuration interface
- Shows all available parameters with descriptions and help text
- Validates inputs in real-time
- Provides parameter grouping and search functionality
- Allows downloading a `params.json` file with your configuration
- Supports loading existing parameter files for editing

**Usage:**
```bash
# Launch for a specific pipeline
nf-core launch nf-core/riboseq

# Launch and specify a tag/version
nf-core launch nf-core/riboseq --revision 1.2.0

# Launch with an existing parameter file to edit
nf-core launch nf-core/riboseq -params-file params.json
```

**Workflow:**
1. Run `nf-core launch nf-core/pipeline`
2. Web browser opens with parameter interface
3. Configure parameters interactively
4. Click "Download" to save `params.json`
5. Use the downloaded file: `nextflow run nf-core/pipeline -params-file params.json`

### 2. Using nf-core pipelines create-params-file

Generate a parameter file template from the pipeline schema:

```bash
nf-core pipelines create-params-file <pipeline_directory>
```

**Features:**
- Creates a `params.yaml` file with all pipeline parameters
- Includes default values and descriptions as comments
- Organized by parameter groups
- Ready for editing and use with `-params-file`

**Usage:**
```bash
# Create params.yaml in current directory for a local pipeline
nf-core pipelines create-params-file /path/to/pipeline

# Create params.yaml with hidden options included
nf-core pipelines create-params-file /path/to/pipeline --show-hidden

# Create params.yaml for a specific pipeline version
nf-core pipelines create-params-file /path/to/pipeline --revision 1.2.0
```

**Example output (`params.yaml`):**
```yaml
# Input/output options
input: null  # Path to comma-separated file containing information about the samples
outdir: null  # The output directory where the results will be saved

# Reference genome options
genome: null  # Name of iGenomes reference
fasta: null  # Path to FASTA genome file
gtf: null  # Path to GTF annotation file

# Trimming options
trimmer: 'trimgalore'  # Tool to use for read trimming
skip_trimming: false  # Skip read trimming step
save_trimmed: false  # Save trimmed reads to output directory

# Analysis options
skip_ribocode: false  # Skip RiboCode analysis
skip_riboorf: false  # Skip RibORF analysis
```

**Best Practices:**
- Uncomment and modify parameters you want to change
- Keep default values for parameters you don't need to customize
- Use `--show-hidden` to include advanced/hidden parameters
- Commit example parameter files (without sensitive data) to version control

### 3. Using nextflow run --help

Generate parameter template from command-line help:

```bash
nextflow run nf-core/pipeline --help > params_template.txt
```

**Note:** This generates a text file with parameter descriptions, but not a directly usable parameter file. Use `nf-core pipelines create-params-file` for a ready-to-use YAML file.

### 4. Manual Parameter File Creation

Create parameter files manually if needed:

```yaml
# Input/Output Options
input: '/path/to/samplesheet.csv'
contrasts: '/path/to/contrasts.csv'
outdir: '/path/to/results'

# Reference Genome Options
genome: 'GRCh38'
# OR
fasta: '/path/to/genome.fasta'
gtf: '/path/to/annotation.gtf'

# Trimming Options
trimmer: 'trimgalore'
skip_trimming: false
save_trimmed: false

# Alignment Options
aligner: 'star'
skip_alignment: false

# Analysis Options
skip_ribocode: false
skip_riboorf: false
skip_ribotish: false

# Tool-Specific Options
extra_star_align_args: '--outFilterMismatchNmax 2'
extra_fastqc_args: '--quiet'

# MultiQC Options
multiqc_title: 'My Ribo-seq Analysis'
skip_multiqc: false
```

### 5. JSON Parameter File

Create `params.json` (typically generated by `nf-core launch`):

```json
{
    "input": "/path/to/samplesheet.csv",
    "contrasts": "/path/to/contrasts.csv",
    "outdir": "/path/to/results",
    "genome": "GRCh38",
    "trimmer": "trimgalore",
    "skip_trimming": false,
    "aligner": "star",
    "skip_ribocode": false,
    "multiqc_title": "My Ribo-seq Analysis"
}
```

### 6. Using Parameter Files

**YAML (from create-params-file):**
```bash
# Edit params.yaml, then run
nextflow run nf-core/pipeline -profile docker -params-file params.yaml
```

**JSON (from launch):**
```bash
# Download params.json from nf-core launch, then run
nextflow run nf-core/pipeline -profile docker -params-file params.json
```

**Override parameters:**
```bash
# Parameters in file can be overridden on command line
nextflow run nf-core/pipeline -profile docker -params-file params.yaml --skip_ribocode
```

### 7. Comparison of Methods

| Method | Best For | Output Format | Interactive | Notes |
|--------|----------|--------------|-------------|-------|
| `nf-core launch` | Interactive configuration | JSON | Yes | Web interface, validation, download |
| `nf-core pipelines create-params-file` | Template generation | YAML | No | Includes defaults and comments |
| `nextflow run --help` | Documentation | Text | No | Parameter descriptions only |
| Manual creation | Custom needs | YAML/JSON | No | Full control, more error-prone |

**Recommended workflow:**
1. **First time:** Use `nf-core launch` for interactive setup
2. **Template creation:** Use `nf-core pipelines create-params-file` for team templates
3. **Quick edits:** Edit YAML/JSON files directly
4. **Documentation:** Use `--help` for parameter reference

### 8. Parameter File Best Practices

1. **Organization:**
   - Group related parameters
   - Use comments in YAML files
   - Keep file structure logical

2. **Documentation:**
   - Include comments explaining choices
   - Document conditional parameters
   - Note required vs. optional parameters

3. **Version Control:**
   - Don't commit parameter files with sensitive data
   - Use `.gitignore` for local parameter files
   - Create example parameter files for documentation

4. **Validation:**
   - Validate parameter files before running
   - Use `--help` to check parameter names
   - Test with `-profile test` first

---

## Testing Modules

### 1. Test File Structure

Create test files in `modules/nf-core/tool/process/tests/`:

```text
modules/nf-core/tool/process/
├── main.nf
├── meta.yml
├── environment.yml
└── tests/
    ├── main.nf.test
    ├── main.nf.test.snap
    └── nextflow.config
```

### 2. Running Module Tests

**Basic test:**
```bash
cd modules/nf-core/tool/process/tests
nf-test test main.nf.test
```

**With specific profile:**
```bash
nf-test test main.nf.test -profile docker
```

**Update snapshots:**
```bash
nf-test test main.nf.test --update-snapshots
```

**Stub tests only:**
```bash
nf-test test main.nf.test -stub
```

### 3. Test Configuration

Create `tests/nextflow.config`:

```groovy
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
    modules_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/'
}
```

### 4. Test Coverage

Test all scenarios:
- [ ] Single-end inputs
- [ ] Paired-end inputs
- [ ] Optional inputs
- [ ] Custom prefixes
- [ ] Stub runs
- [ ] Edge cases

See [NF_TEST_BEST_PRACTICES.md](NF_TEST_BEST_PRACTICES.md) for detailed guidance.

---

## Testing Subworkflows

### 1. Test File Structure

Create test files in `subworkflows/nf-core/subworkflow_name/tests/`:

```text
subworkflows/nf-core/subworkflow_name/
├── main.nf
├── meta.yml
└── tests/
    ├── main.nf.test
    ├── main.nf.test.snap
    └── nextflow.config
```

### 2. Subworkflow Test Example

```groovy
nextflow_workflow {

    name "Test Subworkflow SUBWORKFLOW_NAME"
    script "../main.nf"
    workflow "SUBWORKFLOW_NAME"

    tag "subworkflows"
    tag "subworkflows_nfcore"
    tag "subworkflow_name"

    test("basic test") {
        when {
            workflow {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: true ],
                    [ file(params.modules_testdata_base_path + 'path/to/test.fastq.gz', checkIfExists: true) ]
                ])
                """
            }
        }

        then {
            assertAll (
                { assert workflow.success },
                { assert workflow.out.output_name[0][1] ==~ ".*/expected.*" },
                { assert snapshot(workflow.out.versions).match() }
            )
        }
    }
}
```

### 3. Running Subworkflow Tests

```bash
cd subworkflows/nf-core/subworkflow_name/tests
nf-test test main.nf.test -profile docker
```

---

## Testing Workflows

### 1. Test Configuration Files

Create test configs in `conf/`:

**`conf/test.config`:**
```groovy
process {
    resourceLimits = [
        cpus: 4,
        memory: '15.GB',
        time: '1.h'
    ]
}

params {
    config_profile_name        = 'Test profile'
    config_profile_description = 'Minimal test dataset to check pipeline function'

    // Input data
    input = 'https://raw.githubusercontent.com/nf-core/test-datasets/pipeline/samplesheet.csv'
    contrasts = 'https://raw.githubusercontent.com/nf-core/test-datasets/pipeline/contrasts.csv'
    
    // Reference data
    fasta = 'https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/homo_sapiens/genome.fasta'
    gtf = 'https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/homo_sapiens/genome.gtf'
    
    // Test-specific overrides
    min_trimmed_reads = 1000
    skip_ribotricer = true
}
```

**`conf/test_full.config`:**
```groovy
// Full test with all modules enabled
includeConfig 'conf/test.config'

params {
    config_profile_name        = 'Full test profile'
    config_profile_description = 'Full test dataset with all modules enabled'
    
    // Enable all analysis modules
    skip_ribotricer = false
    skip_ribocode = false
    skip_riboorf = false
}
```

### 2. Running Workflow Tests

**Minimal test:**
```bash
nextflow run . -profile test,docker --outdir test_results
```

**Full test:**
```bash
nextflow run . -profile test_full,docker --outdir test_results
```

**Test with custom parameters:**
```bash
nextflow run . -profile test,docker --outdir test_results --skip_ribocode
```

### 3. CI/CD Testing

**GitHub Actions example:**

```yaml
name: Test Pipeline
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Nextflow
        run: |
          wget -qO- https://get.nextflow.io | bash
          sudo mv nextflow /usr/local/bin/
      
      - name: Run test profile
        run: |
          nextflow run . -profile test,docker --outdir test_results
      
      - name: Run test_full profile
        run: |
          nextflow run . -profile test_full,docker --outdir test_results_full
```

### 4. Test Data Management

**Using nf-core test datasets:**
```groovy
params {
    pipelines_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/'
    modules_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/'
}
```

**Local test data:**
```groovy
params {
    input = "${projectDir}/tests/data/samplesheet.csv"
    fasta = "${projectDir}/tests/data/genome.fasta"
    gtf = "${projectDir}/tests/data/genome.gtf"
}
```

### 5. Test Best Practices

1. **Test Profiles:**
   - Create minimal test profile (`test.config`)
   - Create full test profile (`test_full.config`)
   - Use small test datasets
   - Set resource limits for CI/CD

2. **Test Coverage:**
   - Test all major workflow paths
   - Test conditional execution
   - Test with different input types
   - Test error handling

3. **Test Data:**
   - Use publicly available test datasets
   - Keep test data small but representative
   - Document test data sources
   - Version test data

4. **CI/CD Integration:**
   - Run tests on every commit
   - Test with multiple profiles (docker, singularity)
   - Test on multiple platforms if possible
   - Fail fast on errors

---

## Test Data Management

### 1. Test Data Sources

**nf-core test datasets:**
- Publicly available on GitHub
- Organized by pipeline and module
- Versioned and tagged
- URL: `https://raw.githubusercontent.com/nf-core/test-datasets/`

**Local test data:**
- Store in `tests/data/`
- Keep files small
- Document data sources
- Version control test data

### 2. Test Data Organization

```text
tests/
├── data/
│   ├── samplesheet.csv
│   ├── genome.fasta
│   ├── genome.gtf
│   └── fastq/
│       ├── sample1_R1.fastq.gz
│       └── sample1_R2.fastq.gz
└── configs/
    └── test_local.config
```

### 3. Test Data Best Practices

1. **Size:**
   - Keep test data minimal but representative
   - Use chromosome subsets for genomes
   - Use small FASTQ files (1000-10000 reads)

2. **Availability:**
   - Use publicly accessible URLs
   - Ensure test data is stable
   - Document data sources

3. **Versioning:**
   - Tag test data versions
   - Document test data changes
   - Keep test data compatible with pipeline versions

---

## Summary Checklists

### nextflow_schema.json
- [ ] All parameters defined
- [ ] Parameters organized into logical groups
- [ ] Required parameters marked
- [ ] Appropriate types and formats
- [ ] Help text included
- [ ] Validation patterns where needed
- [ ] Defaults set appropriately
- [ ] Icons included for UI

### modules.json
- [ ] Generated using nf-core CLI tools
- [ ] All modules tracked
- [ ] Git SHAs accurate
- [ ] `installed_by` fields correct
- [ ] Committed to version control

### nextflow.config
- [ ] All parameters defined with defaults
- [ ] Profiles for all execution environments
- [ ] Base config included
- [ ] Modules config included
- [ ] Environment variables set
- [ ] Shell options configured
- [ ] Manifest complete
- [ ] Plugins configured

### HPC Configurations
- [ ] Executor configured correctly
- [ ] Queue names appropriate
- [ ] Resource limits match cluster
- [ ] Container support configured
- [ ] Storage paths correct
- [ ] Cluster-specific options set

### AWS Batch Configurations
- [ ] Batch queue configured
- [ ] IAM roles set up
- [ ] Storage strategy defined (S3/EFS)
- [ ] Container images in ECR
- [ ] Resource mapping correct
- [ ] Cost optimization considered

### Parameter Files
- [ ] Generated using nf-core launch or manually
- [ ] Well-organized and documented
- [ ] Validated before use
- [ ] Sensitive data excluded from version control

### Testing
- [ ] Module tests created
- [ ] Subworkflow tests created
- [ ] Workflow test profiles created
- [ ] Test data available
- [ ] CI/CD integration configured
- [ ] Tests run successfully

---

## References

- [Nextflow Configuration Documentation](https://www.nextflow.io/docs/latest/config.html)
- [Nextflow Schema Documentation](https://www.nextflow.io/docs/latest/schema.html)
- [nf-core Schema Guidelines](https://nf-co.re/docs/contributing/guidelines#schema)
- [nf-core Module Testing](https://nf-co.re/docs/contributing/modules_testing)
- [Nextflow AWS Batch](https://www.nextflow.io/docs/latest/awscloud.html#aws-batch)
- [Nextflow Executors](https://www.nextflow.io/docs/latest/executor.html)

### Related Documentation

- [NF_TEST_BEST_PRACTICES.md](NF_TEST_BEST_PRACTICES.md) - Detailed testing guide
- [MODULES_CONFIG_BEST_PRACTICES.md](MODULES_CONFIG_BEST_PRACTICES.md) - Module configuration guide
- [CONTAINER_MANAGEMENT_BEST_PRACTICES.md](CONTAINER_MANAGEMENT_BEST_PRACTICES.md) - Comprehensive guide on conda/mamba environments, Docker, Singularity, cross-platform images, and container management

