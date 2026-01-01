---
layout: post
title: "Best Practices for Developing Nextflow Modules"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, modules, bioinformatics, workflows, best-practices, development]
author: Haibo Liu, PhD
toc: true
---


This document outlines best practices for developing Nextflow modules, covering the complete module development lifecycle from initial design to testing and maintenance.


## Module Structure and Organization

### 1. Directory Structure

Organize modules in a clear, hierarchical structure:

```text
modules/
├── nf-core/              # nf-core standard modules
│   ├── tool_name/
│   │   ├── process_name/
│   │   │   ├── main.nf           # Main process definition
│   │   │   ├── meta.yml          # Module metadata
│   │   │   ├── environment.yml   # Conda environment
│   │   │   ├── Dockerfile        # Custom Dockerfile (if needed)
│   │   │   ├── README.md         # Additional documentation (optional)
│   │   │   ├── templates/         # Template scripts (if needed)
│   │   │   │   └── script.r
│   │   │   └── tests/             # Test files
│   │   │       ├── main.nf.test
│   │   │       ├── main.nf.test.snap
│   │   │       ├── nextflow.config
│   │   │       └── tags.yml
│   └── local/            # Pipeline-specific modules
│       └── tool_name/
│           └── process_name/
│               └── main.nf
```

### 2. Module Naming

- **Tool name**: Lowercase, descriptive (e.g., `fastqc`, `samtools`, `star`)
- **Process name**: Descriptive action (e.g., `index`, `align`, `sort`, `quality`)
- **Process ID**: UPPER_SNAKE_CASE (e.g., `FASTQC`, `SAMTOOLS_INDEX`, `STAR_ALIGN`)

---

## Required Files

### 1. `main.nf` - Process Definition

The core process definition file. See [MODULE_MAIN_NF_BEST_PRACTICES.md](MODULE_MAIN_NF_BEST_PRACTICES.md) for detailed guidance.

**Minimum structure:**

```groovy
process MODULE_NAME {
    tag "$meta.id"
    label 'process_medium'

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

### 2. `meta.yml` - Module Metadata

Comprehensive metadata for the module:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/nf-core/modules/master/modules/meta-schema.json
name: "module_name"
description: Brief description of what the module does
keywords:
  - keyword1
  - keyword2
  - keyword3

tools:
  - tool_name:
      description: |
        Detailed description of the tool and what it does.
        Can span multiple lines.
      homepage: https://tool-website.com
      documentation: https://tool-docs.com
      tool_dev_url: https://github.com/tool/repo
      doi: "10.1234/example.doi"
      licence: ["MIT", "GPL-2.0"]
      identifier: biotools:tool_name

input:
  - - meta:
        type: map
        description: |
          Groovy Map containing sample information
          e.g. [ id:'test', single_end:false ]
    - input_file:
        type: file
        description: Description of input file
        pattern: "*.{ext1,ext2}"
        ontologies:
          - edam: http://edamontology.org/format_XXXX

output:
  - output_name:
      - meta:
          type: map
          description: |
            Groovy Map containing sample information
      - "*.output":
          type: file
          description: Description of output file
          pattern: "*.output"
          ontologies:
            - edam: http://edamontology.org/format_XXXX
  - versions:
      - versions.yml:
          type: file
          description: File containing software versions
          pattern: "versions.yml"
          ontologies:
            - edam: http://edamontology.org/format_3750 # YAML

authors:
  - "@github_username"
maintainers:
  - "@github_username"
```

**Key Fields:**
- `name`: Module name (lowercase, no spaces)
- `description`: Clear, concise description
- `keywords`: Searchable keywords
- `tools`: Tool information (homepage, docs, license, DOI)
- `input`/`output`: Detailed channel structure definitions
- `authors`: Original creators
- `maintainers`: Current maintainers

### 3. `environment.yml` - Conda Environment

Define Conda dependencies:

```yaml
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/nf-core/modules/master/modules/environment-schema.json
channels:
  - conda-forge
  - bioconda
dependencies:
  - bioconda::tool_name=1.2.3
  - conda-forge::dependency=4.5.6
```

**Best Practices:**
- Use `bioconda::` prefix for bioinformatics tools
- Use `conda-forge::` for general dependencies
- Pin versions for reproducibility
- List all dependencies explicitly
- Match versions with container images when possible

### 4. `Dockerfile` (Optional)

Create a custom Dockerfile when:
- Tool is not available in biocontainers/bioconda
- Custom build process is required
- Multiple tools need to be combined
- Complex dependencies need special handling

**Example structure:**

```dockerfile
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    perl \
    && rm -rf /var/lib/apt/lists/*

# Install Perl dependencies
RUN cpanm --notest Getopt::Std

# Clone and install tool
RUN git clone https://github.com/tool/repo.git /opt/tool && \
    cd /opt/tool && \
    chmod +x *.pl

# Install Python dependencies
RUN pip install --no-cache-dir pysam numpy scipy pandas

# Add to PATH
ENV PATH="/opt/tool:${PATH}"

# Verify installation
RUN tool --version
```

### 5. `README.md` (Optional)

Additional documentation for complex modules:

- Build instructions for custom Dockerfiles
- Usage examples
- Special configuration requirements
- Known issues or limitations
- Workflow details for complex tools

---

## Naming Conventions

### 1. Process Names

Use UPPER_SNAKE_CASE with descriptive names:

```groovy
// Good
process FASTQC { }
process SAMTOOLS_INDEX { }
process STAR_ALIGN { }
process RIBOCODE_DETECT_ORFS { }

// Avoid
process fastqc { }           // Wrong case
process INDEX { }            // Too generic
process TOOL { }             // Not descriptive
```

### 2. Channel Names

Use descriptive, lowercase names:

```groovy
// Good
emit: reads
emit: bam
emit: stats
emit: html
emit: json

// Avoid
emit: out1
emit: output
emit: file
```

### 3. File Patterns

Use clear, specific patterns:

```groovy
// Good
path("*.bam")
path("*.{bam,bai}")
path("*.tsv{,.gz}")
path("results/*.txt")

// Avoid
path("*")                    // Too broad
path("file")                 // Too specific
path("*.{bam,txt,log}")      // Unrelated types
```

---

## Process Definition

### 1. Standard Structure

Follow this order in `main.nf`:

```groovy
process MODULE_NAME {
    // 1. Tag and label
    tag "$meta.id"
    label 'process_medium'

    // 2. Container and environment
    conda "${moduleDir}/environment.yml"
    container "..."

    // 3. Inputs
    input:
    // ...

    // 4. Outputs
    output:
    // ...

    // 5. When condition
    when:
    task.ext.when == null || task.ext.when

    // 6. Script
    script:
    // ...

    // 7. Stub
    stub:
    // ...
}
```

### 2. Tag and Label

**Tag:** Use metadata ID for sample tracking:

```groovy
tag "$meta.id"              // Standard
tag "${meta.id}"            // Alternative syntax
```

**Label:** Choose appropriate resource label:

```groovy
label 'process_single'      // 1 CPU, minimal RAM
label 'process_low'         // 2-4 CPUs, 4-8GB RAM
label 'process_medium'      // 4-8 CPUs, 8-16GB RAM
label 'process_high'        // 8+ CPUs, 16+ GB RAM
```

### 3. Container Configuration

**Standard format:**

```groovy
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/tool:version--build' :
    'biocontainers/tool:version--build' }"
```

**Custom Dockerfile:**

```groovy
container "docker.io/username/tool:version"
```

**Best Practices:**

- Use `quay.io/biocontainers/` prefix for biocontainers
- Match container version with conda version
- Verify container availability before committing
- Document custom Dockerfiles in README.md
- See [CONTAINER_MANAGEMENT_BEST_PRACTICES.md](CONTAINER_MANAGEMENT_BEST_PRACTICES.md) for detailed guidance

---

## Input/Output Design

### 1. Input Channel Structure

Always include metadata as first element:

```groovy
input:
tuple val(meta), path(input_file)                    // Single file
tuple val(meta), path(reads)                          // List of files
tuple val(meta), path(file1), path(file2)            // Multiple files
tuple val(meta), path(file), val(param1), val(param2) // Files + parameters
```

**Best Practices:**
- Always include `meta` map for sample tracking
- Use `val()` for metadata and non-file values
- Use `path()` for files that need staging
- Group related inputs in tuples
- Mark optional inputs in comments

### 2. Output Channel Structure

Define all possible outputs:

```groovy
output:
tuple val(meta), path("*.bam")              , emit: bam
tuple val(meta), path("*.log")              , emit: log
tuple val(meta), path("*.json")             , emit: json, optional: true
tuple val(meta), path("*.html")             , emit: html, optional: true
path "versions.yml"                         , emit: versions
// For Nextflow 24.04+: use topic channels
// path "versions.yml"                         , topic: versions
```

**Best Practices:**
- Use descriptive channel names
- Mark optional outputs with `optional: true`
- Always emit `versions.yml`
- Use glob patterns for flexibility
- Document output structure in `meta.yml`

### 3. Metadata Handling

Preserve and extend metadata:

```groovy
// Preserve metadata through workflow
tuple val(meta), path(output)

// Extend metadata
.map { meta, data -> [meta + [processed: true], data] }

// Filter based on metadata
.filter { meta, data -> meta.sample_type == 'riboseq' }
```

---

## Container and Environment Setup

### 1. Container Image Selection

**Priority order:**

1. **Biocontainers** (preferred):
   ```groovy
   container "quay.io/biocontainers/tool:version--build"
   ```

2. **Custom Dockerfile** (when unavailable):
   ```groovy
   container "docker.io/username/tool:version"
   ```

3. **Other registries** (as last resort):
   ```groovy
   container "registry.example.com/tool:version"
   ```

**Verification:**
- Check image availability before committing
- Test with both Docker and Singularity
- Document any custom images in README.md

### 2. Environment.yml Best Practices

```yaml
---
channels:
  - conda-forge
  - bioconda

dependencies:
  # Primary tool (pinned version)
  - bioconda::tool_name=1.2.3
  
  # Dependencies (let conda resolve)
  - bioconda::dependency1
  - conda-forge::dependency2
  
  # Python packages
  - pip
  - pip:
      - package_name==1.2.3
```

**Best Practices:**
- Pin primary tool version
- Let conda resolve dependency versions
- Use `bioconda::` for bioinformatics tools
- Use `conda-forge::` for general tools
- Match versions with container when possible

### 3. Version Synchronization

Keep versions synchronized:

```groovy
// main.nf
container "quay.io/biocontainers/tool:1.2.3--build"

// environment.yml
dependencies:
  - bioconda::tool=1.2.3

// Version detection in script
tool: \$(tool --version 2>&1 | sed -e "s/tool //g")
```

---

## Testing

Nextflow modules should be tested using the `nf-test` framework. See [NF_TEST_BEST_PRACTICES.md](NF_TEST_BEST_PRACTICES.md) for comprehensive testing guidance.

### 1. Test File Structure

Create comprehensive test files:

```groovy
// tests/main.nf.test
nextflow_process {

    name "Test Process MODULE_NAME"
    script "../main.nf"
    process "MODULE_NAME"

    tag "modules"
    tag "modules_nfcore"
    tag "tool_name"

    test("basic single-end test") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: true ],
                    file(params.modules_testdata_base_path + 'path/to/test.fastq.gz', checkIfExists: true)
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.output_name[0][1] ==~ ".*/test_output.*" },
                { assert path(process.out.output_name[0][1]).exists() },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("paired-end test") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: false ],
                    [
                        file(params.modules_testdata_base_path + 'path/to/test_1.fastq.gz', checkIfExists: true),
                        file(params.modules_testdata_base_path + 'path/to/test_2.fastq.gz', checkIfExists: true)
                    ]
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.output_name[0][1][0] ==~ ".*/test_1_output.*" },
                { assert process.out.output_name[0][1][1] ==~ ".*/test_2_output.*" },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("stub test") {
        options "-stub"
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: true ],
                    file(params.modules_testdata_base_path + 'path/to/test.fastq.gz', checkIfExists: true)
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert snapshot(process.out).match() }
            )
        }
    }
}
```

### 2. Test Configuration

Create test-specific config files:

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
    modules_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/'
}
```

### 3. Test Coverage

Test all scenarios:

- [ ] Single-end inputs
- [ ] Paired-end inputs
- [ ] Optional inputs
- [ ] Custom prefixes
- [ ] Stub runs
- [ ] Edge cases (empty files, special characters)
- [ ] Version detection
- [ ] Output file patterns

### 4. Snapshot Testing

Use snapshots for output validation:

```groovy
{ assert snapshot(process.out.versions).match() }
{ assert snapshot(process.out).match() }
```

**Benefits:**
- Catches unexpected changes
- Validates output structure
- Easy to update when intentional changes occur

---

## Documentation

### 1. Meta.yml Documentation

Comprehensive `meta.yml` is essential:

```yaml
name: "module_name"
description: |
  Clear, concise description of what the module does.
  Can include multiple sentences and details about
  the tool's purpose and use cases.

keywords:
  - primary_keyword
  - secondary_keyword
  - related_term

tools:
  - tool_name:
      description: |
        Detailed tool description explaining:
        - What the tool does
        - When to use it
        - Key features
      homepage: https://tool-website.com
      documentation: https://tool-docs.com
      tool_dev_url: https://github.com/tool/repo
      doi: "10.1234/example.doi"
      licence: ["MIT"]
      identifier: biotools:tool_name
```

### 2. Inline Comments

Document complex logic in `main.nf`:

```groovy
script:
def args = task.ext.args ?: ''
def prefix = task.ext.prefix ?: "${meta.id}"

// Calculate memory for FastQC (memory per thread)
// FastQC memory value allowed range (100 - 10000 MB)
// See: https://github.com/s-andrews/FastQC/blob/...
def memory_in_mb = task.memory ? task.memory.toUnit('MB') / task.cpus : null
def fastqc_memory = memory_in_mb > 10000 ? 10000 : (memory_in_mb < 100 ? 100 : memory_in_mb)
```

### 3. README.md (For Complex Modules)

Include when:
- Custom Dockerfile is used
- Complex workflow is implemented
- Special configuration is required
- Known issues or limitations exist

**Example sections:**
- Overview
- Building the Docker Image
- Usage
- Workflow Details
- Troubleshooting

---

## Versioning and Updates

### 1. Version Detection

Always detect and record tool versions:

```groovy
script:
"""
tool $args input_file

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool_name: \$(tool --version 2>&1 | sed -e "s/tool //g")
    dependency: \$(dependency --version 2>&1 | sed 's/^.*version //; s/ .*\$//')
END_VERSIONS
"""
```

**Common patterns:**

```bash
# Simple version
tool --version

# Extract from verbose output
tool --version 2>&1 | sed -e "s/tool //g"

# Multi-line output
echo $(tool --version 2>&1) | sed 's/^.*version //; s/ .*$//'

# R package
Rscript -e "cat(as.character(packageVersion('package')))"

# Python package
python -c "import package; print(package.__version__)"
```

### 2. Version Updates

When updating module versions:

1. **Update container image:**
   ```groovy
   container "quay.io/biocontainers/tool:1.3.0--new_build"
   ```

2. **Update environment.yml:**
   ```yaml
   dependencies:
     - bioconda::tool=1.3.0
   ```

3. **Update version detection:**
   ```groovy
   tool_name: \$(tool --version 2>&1 | sed -e "s/tool //g")
   ```

4. **Update stub version:**
   ```groovy
   stub:
   """
   tool_name: "1.3.0"
   """
   ```

5. **Test thoroughly:**
   - Run all tests
   - Verify version detection
   - Check for breaking changes

### 3. Changelog

Document version changes:

```markdown
## [1.3.0] - 2024-01-15

### Changed
- Updated tool from 1.2.3 to 1.3.0
- Updated container image to `quay.io/biocontainers/tool:1.3.0--build`
- Improved version detection

### Fixed
- Fixed issue with paired-end input handling
```

---

## Common Pitfalls

### 1. Missing Metadata

**Wrong:**
```groovy
input:
path(input_file)  // No metadata!
```

**Correct:**
```groovy
input:
tuple val(meta), path(input_file)  // Always include metadata
```

### 2. Incorrect File Patterns

**Wrong:**
```groovy
path("output")           // Too specific, won't match
path("*")                // Too broad, matches everything
```

**Correct:**
```groovy
path("*.bam")            // Specific pattern
path("*.{bam,bai}")      // Multiple extensions
path("results/*.txt")    // With directory
```

### 3. Version Detection Failures

**Wrong:**
```groovy
tool_name: \$(tool --version)  // May include extra text
```

**Correct:**
```groovy
tool_name: \$(tool --version 2>&1 | sed -e "s/tool //g")
```

### 4. Missing Stub Implementation

**Wrong:**
```groovy
stub:
"""
# Empty stub
"""
```

**Correct:**
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

### 5. Container Image Mismatches

**Wrong:**
```groovy
// Container version doesn't match environment.yml
container "quay.io/biocontainers/tool:1.2.3--build"
// environment.yml has tool=1.3.0
```

**Correct:**
```groovy
// Keep versions synchronized
container "quay.io/biocontainers/tool:1.2.3--build"
// environment.yml: bioconda::tool=1.2.3
```

### 6. Incomplete Meta.yml

**Wrong:**
```yaml
name: tool
# Missing description, keywords, tool info, etc.
```

**Correct:**
```yaml
name: "tool_name"
description: Clear description
keywords: [keyword1, keyword2]
tools:
  - tool_name:
      description: Tool description
      homepage: https://...
      # ... complete tool information
```

---

## Module Development Workflow

### 1. Planning Phase

Before writing code:

- [ ] Check if module already exists
- [ ] Review tool documentation
- [ ] Identify required inputs/outputs
- [ ] Determine container/environment needs
- [ ] Plan test scenarios

### 2. Development Phase

#### Step 1: Create directory structure

```bash
mkdir -p modules/nf-core/tool/process/{tests,templates}
```

#### Step 2: Create `main.nf`

- Define process structure
- Implement script logic
- Add stub implementation
- Test locally

#### Step 3: Create `meta.yml`

- Fill in all required fields
- Document inputs/outputs
- Add tool information
- Include keywords

#### Step 4: Create `environment.yml`

- List all dependencies
- Pin tool version
- Test conda installation

#### Step 5: Create tests

- Write test file
- Test all scenarios
- Generate snapshots
- Verify versions

### 3. Testing Phase

**Local testing with nf-test:**

```bash
# Run all tests
cd modules/nf-core/tool/process/tests
nf-test test main.nf.test

# Test with specific profile
nf-test test main.nf.test -profile docker

# Test stub only
nf-test test main.nf.test -stub

# Update snapshots
nf-test test main.nf.test --update-snapshots
```

**Validation checklist:**

- [ ] All tests pass
- [ ] Version detection works
- [ ] Output files match patterns
- [ ] Stub runs successfully
- [ ] Container images available
- [ ] Conda environment installs

### 4. Documentation Phase

- [ ] Complete `meta.yml`
- [ ] Add inline comments
- [ ] Create README.md if needed
- [ ] Document any special requirements

### 5. Review Phase

- [ ] Code review
- [ ] Test coverage review
- [ ] Documentation review
- [ ] Version synchronization check
- [ ] Container availability check

---

## Example: Complete Module

### Directory Structure

```text
modules/nf-core/example_tool/process/
├── main.nf
├── meta.yml
├── environment.yml
└── tests/
    ├── main.nf.test
    ├── main.nf.test.snap
    └── nextflow.config
```

### `main.nf`

```groovy
process EXAMPLE_TOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/example-tool:1.0.0--h1234567_0' :
        'quay.io/biocontainers/example-tool:1.0.0--h1234567_0' }"

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
    example_tool \\
        --input $input_file \\
        --output ${prefix}.output \\
        --threads $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        example-tool: \$(example_tool --version 2>&1 | sed -e "s/example-tool //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        example-tool: "1.0.0"
    END_VERSIONS
    """
}
```

### `meta.yml`

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/nf-core/modules/master/modules/meta-schema.json
name: "example_tool"
description: Brief description of what the module does
keywords:
  - keyword1
  - keyword2

tools:
  - example-tool:
      description: |
        Detailed description of the tool and what it does.
        Can span multiple lines.
      homepage: https://example-tool.com
      documentation: https://example-tool.com/docs
      tool_dev_url: https://github.com/example/tool
      licence: ["MIT"]
      identifier: biotools:example-tool

input:
  - - meta:
        type: map
        description: |
          Groovy Map containing sample information
          e.g. [ id:'test' ]
    - input_file:
        type: file
        description: Input file description
        pattern: "*.input"
        ontologies: []

output:
  - output:
      - meta:
          type: map
          description: |
            Groovy Map containing sample information
      - "*.output":
          type: file
          description: Output file description
          pattern: "*.output"
          ontologies: []
  - versions:
      - versions.yml:
          type: file
          description: File containing software versions
          pattern: "versions.yml"
          ontologies:
            - edam: http://edamontology.org/format_3750 # YAML

authors:
  - "@github_username"
maintainers:
  - "@github_username"
```

### `environment.yml`

```yaml
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/nf-core/modules/master/modules/environment-schema.json
channels:
  - conda-forge
  - bioconda
dependencies:
  - bioconda::example-tool=1.0.0
```

### `tests/main.nf.test`

```groovy
nextflow_process {

    name "Test Process EXAMPLE_TOOL"
    script "../main.nf"
    process "EXAMPLE_TOOL"

    tag "modules"
    tag "modules_nfcore"
    tag "example_tool"

    test("basic test") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test' ],
                    file(params.modules_testdata_base_path + 'path/to/test.input', checkIfExists: true)
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.output[0][1] ==~ ".*/test.output" },
                { assert path(process.out.output[0][1]).exists() },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("stub test") {
        options "-stub"
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test' ],
                    file(params.modules_testdata_base_path + 'path/to/test.input', checkIfExists: true)
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert snapshot(process.out).match() }
            )
        }
    }
}
```

### `tests/nextflow.config`

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

---

## Summary Checklist

When developing a Nextflow module:

### Structure
- [ ] Correct directory structure
- [ ] All required files present
- [ ] Proper naming conventions

### `main.nf`
- [ ] Process name follows conventions
- [ ] Tag uses `$meta.id`
- [ ] Appropriate label set
- [ ] Container and conda specified
- [ ] Inputs include metadata
- [ ] Outputs properly defined
- [ ] Script implements tool correctly
- [ ] Stub matches script structure
- [ ] Version detection implemented

### `meta.yml`
- [ ] Complete tool information
- [ ] Input/output structures documented
- [ ] Keywords included
- [ ] Authors/maintainers listed

### `environment.yml`
- [ ] Dependencies listed
- [ ] Versions pinned
- [ ] Channels specified

### Testing
- [ ] Test file created
- [ ] Multiple test scenarios
- [ ] Stub test included
- [ ] All tests pass
- [ ] Snapshots generated

### Documentation
- [ ] Inline comments added
- [ ] Complex logic explained
- [ ] README.md created if needed

### Validation
- [ ] Container images available
- [ ] Versions synchronized
- [ ] No linter errors
- [ ] Follows nf-core conventions

---

## References

- [Nextflow Process Documentation](https://www.nextflow.io/docs/latest/process.html)
- [nf-core Module Guidelines](https://nf-co.re/docs/contributing/modules)
- [nf-core Module Testing Guidelines](https://nf-co.re/docs/contributing/modules_testing)
- [MODULE_MAIN_NF_BEST_PRACTICES.md](MODULE_MAIN_NF_BEST_PRACTICES.md) - Detailed guide for writing `main.nf`
- [MODULES_CONFIG_BEST_PRACTICES.md](MODULES_CONFIG_BEST_PRACTICES.md) - Guide for configuring modules
- Current pipeline modules: `modules/nf-core/*/main.nf`
