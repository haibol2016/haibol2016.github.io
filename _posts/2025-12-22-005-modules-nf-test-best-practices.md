---
layout: post
title: "Best Practices for Writing nf-test Test Files for Nextflow Modules"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, modules, testing, nf-test, bioinformatics, workflows, best-practices]
author: Haibo Liu, PhD
---


This document outlines best practices for writing comprehensive nf-test test files for Nextflow modules, covering test structure, patterns, assertions, and configuration.


## Test File Structure

### 1. File Location

Place test files in the module's `tests/` directory:

```text
modules/nf-core/tool/process/
├── main.nf
├── meta.yml
├── environment.yml
└── tests/
    ├── main.nf.test          # Main test file
    ├── main.nf.test.snap     # Snapshot file (auto-generated)
    ├── nextflow.config       # Test configuration
    └── tags.yml              # Optional: test tags
```

### 2. Basic Test File Template

```groovy
nextflow_process {

    name "Test Process PROCESS_NAME"
    script "../main.nf"
    process "PROCESS_NAME"

    tag "modules"
    tag "modules_nfcore"
    tag "tool_name"
    tag "tool_name/process_name"

    test("test_description") {
        // Optional: config "./nextflow.config"
        // Optional: options "-stub"
        // Optional: setup { ... }

        when {
            process {
                """
                input[0] = channel.of([...])
                input[1] = channel.of([...])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.output_name[0][1] ==~ ".*/expected_pattern.*" },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }
}
```

---

## Basic Test Structure

### 1. Test Block Header

```groovy
nextflow_process {
    name "Test Process PROCESS_NAME"
    script "../main.nf"
    process "PROCESS_NAME"

    tag "modules"
    tag "modules_nfcore"
    tag "tool_name"
    tag "tool_name/process_name"  // Optional: for nested modules
}
```

**Key Elements:**

- `name`: Descriptive test suite name
- `script`: Relative path to module's `main.nf`
- `process`: Exact process name from `main.nf`
- `tag`: Tags for test organization and filtering

### 2. Individual Test Structure

```groovy
test("descriptive_test_name") {
    // Optional configuration
    config "./nextflow.config"
    options "-stub"
    
    // Optional setup for dependencies
    setup { ... }

    when {
        process {
            """
            // Input channel definitions
            """
        }
        params {
            // Optional parameter overrides
            param_name = "value"
        }
    }

    then {
        assertAll (
            // Assertions
        )
    }
}
```

---

## Test Naming Conventions

### 1. Test Names

Use descriptive, lowercase names with underscores:

```groovy
// Good
test("sarscov2 single-end [fastq]")
test("homo_sapiens - paired_end")
test("test_fastp_single_end_trim_fail")
test("sarscov2 custom_prefix")

// Avoid
test("test1")
test("Test Single End")
test("test-single-end")
```

### 2. Naming Patterns

Follow consistent patterns:

```groovy
// Dataset - Input type
test("sarscov2 single-end [fastq]")
test("sarscov2 paired-end [fastq]")
test("sarscov2 paired-end [bam]")

// Feature - Input type
test("test_fastp_single_end")
test("test_fastp_paired_end_merged")
test("test_fastp_single_end_qc_only")

// Configuration variant
test("homo_sapiens - paired_end - arriba")
test("homo_sapiens - paired_end - starfusion")

// Stub tests
test("sarscov2 single-end [fastq] - stub")
test("test_fastp_single_end - stub")
```

---

## Input Channel Setup

### 1. Basic Input Structure

Always include metadata as the first element:

```groovy
when {
    process {
        """
        input[0] = channel.of([
            [ id: 'test', single_end: true ],  // meta map
            file(params.modules_testdata_base_path + 'path/to/file.fastq.gz', checkIfExists: true)
        ])
        """
    }
}
```

### 2. Single-End Inputs

```groovy
input[0] = channel.of([
    [ id: 'test', single_end: true ],
    [ file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true) ]
])
```

### 3. Paired-End Inputs

```groovy
input[0] = channel.of([
    [ id: 'test', single_end: false ],
    [
        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true),
        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_2.fastq.gz', checkIfExists: true)
    ]
])
```

### 4. Multiple Input Channels

```groovy
input[0] = channel.of([
    [ id: 'test', single_end: true ],
    file(params.modules_testdata_base_path + 'path/to/input1.fastq.gz', checkIfExists: true)
])
input[1] = channel.of([
    [ id: 'reference' ],
    file(params.modules_testdata_base_path + 'path/to/reference.fasta', checkIfExists: true)
])
input[2] = false  // Boolean parameter
input[3] = 'illumina'  // String parameter
```

### 5. Empty Lists for Optional Inputs

```groovy
adapter_fasta = []  // Empty list for no adapter file

input[0] = channel.of([
    [ id: 'test', single_end: true ],
    [ file(...) ],
    adapter_fasta
])
```

### 6. Using Variables

```groovy
when {
    process {
        """
        adapter_fasta = []
        discard_trimmed_pass = false
        save_trimmed_fail = false
        save_merged = false

        input[0] = channel.of([
            [ id: 'test', single_end: true ],
            [ file(...) ],
            adapter_fasta
        ])
        input[1] = discard_trimmed_pass
        input[2] = save_trimmed_fail
        input[3] = save_merged
        """
    }
}
```

### 7. File References

Always use `checkIfExists: true`:

```groovy
file(params.modules_testdata_base_path + 'path/to/file.fastq.gz', checkIfExists: true)
```

**Best Practices:**

- Use `params.modules_testdata_base_path` for test data
- Always include `checkIfExists: true`
- Use relative paths from the test data base
- Comment metadata maps for clarity

---

## Assertions and Validation

### 1. Basic Assertions

```groovy
then {
    assertAll (
        { assert process.success },
        { assert process.out.output_name[0][1] ==~ ".*/expected_pattern.*" },
        { assert path(process.out.output_name[0][1]).exists() }
    )
}
```

### 2. Success Assertion

Always check process success first:

```groovy
{ assert process.success }
```

### 3. Output File Pattern Matching

Use regex patterns for flexible matching:

```groovy
// Single output
{ assert process.out.html[0][1] ==~ ".*/test_fastqc.html" }

// Paired outputs
{ assert process.out.html[0][1][0] ==~ ".*/test_1_fastqc.html" }
{ assert process.out.html[0][1][1] ==~ ".*/test_2_fastqc.html" }

// Multiple outputs
{ assert process.out.html[0][1][0] ==~ ".*/test_1_fastqc.html" }
{ assert process.out.html[0][1][1] ==~ ".*/test_2_fastqc.html" }
{ assert process.out.html[0][1][2] ==~ ".*/test_3_fastqc.html" }
```

### 4. File Content Validation

Check file contents for expected values:

```groovy
{ assert path(process.out.html[0][1]).text.contains("<tr><td>File type</td><td>Conventional base calls</td></tr>") }
{ assert path(process.out.log[0][1]).text.contains("reads passed filter: 99") }
{ assert path(process.out.log[0][1]).text.contains("Q30 bases: 12281(88.3716%)") }
```

### 5. File Existence Checks

```groovy
{ assert path(process.out.output_name[0][1]).exists() }
```

### 6. Empty Output Validation

For optional outputs that should be empty:

```groovy
{ assert process.out.reads_fail == [] }
{ assert process.out.reads_merged == [] }
{ assert process.out.gffread_gff == [] }
```

### 7. BAM File Validation

For BAM files, use specialized assertions:

```groovy
{ assert bam(process.out.bam[0][1]).getReadsMD5() == "expected_md5" }
{ assert snapshot(
    bam(process.out.bam[0][1]).getReadsMD5(),
    bam(process.out.bam_sorted_aligned[0][1]).getReadsMD5()
).match() }
```

### 8. File Name Extraction

Extract file names for snapshot testing:

```groovy
{ assert snapshot(
    file(process.out.log_final[0][1]).name,
    file(process.out.log_out[0][1]).name,
    process.out.versions
).match() }
```

### 9. Failure Testing

Test expected failures:

```groovy
then {
    assertAll (
        { assert !process.success },  // Expect failure
        { assert snapshot(process.out).match() }
    )
}
```

---

## Snapshot Testing

### 1. Basic Snapshot

```groovy
{ assert snapshot(process.out.versions).match() }
```

### 2. Full Output Snapshot

```groovy
{ assert snapshot(process.out).match() }
```

### 3. Selective Snapshot

```groovy
{ assert snapshot(
    process.out.reads,
    process.out.reads_fail,
    process.out.reads_merged,
    process.out.versions
).match() }
```

### 4. Snapshot with File Names

```groovy
{ assert snapshot(
    file(process.out.log_final[0][1]).name,
    file(process.out.log_out[0][1]).name,
    file(process.out.log_progress[0][1]).name,
    process.out.versions
).match() }
```

### 5. Snapshot with BAM MD5

```groovy
{ assert snapshot(
    file(process.out.log_final[0][1]).name,
    bam(process.out.bam[0][1]).getReadsMD5(),
    bam(process.out.bam_sorted_aligned[0][1]).getReadsMD5(),
    process.out.versions
).match() }
```

**Best Practices:**

- Always snapshot `versions.yml`
- Snapshot outputs that may change between runs
- Use file names instead of full paths when possible
- For BAM files, use MD5 hashes instead of full files
- Update snapshots when intentional changes are made

---

## Test Configuration Files

### 1. Basic Configuration

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

### 2. Module-Specific Configuration

Override module parameters:

```groovy
process {
    withName: 'MODULE_NAME' {
        ext.args = '--custom-flag'
    }
}
```

### 3. Multiple Configuration Files

Create variant configs for different scenarios:

```groovy
// tests/nextflow.config (default)
// tests/nextflow.interleaved.config
// tests/nextflow.save_failed.config
// tests/nextflow.arriba.config
// tests/nextflow.starfusion.config
```

**Usage:**

```groovy
test("test_name") {
    config "./nextflow.interleaved.config"
    // ...
}
```

### 4. Parameter Overrides in Tests

Override parameters directly in test:

```groovy
when {
    params {
        outdir = "$outputDir"
        custom_param = "value"
    }
    process {
        """
        // ...
        """
    }
}
```

---

## Test Scenarios

### 1. Basic Scenarios

Test all input types:

- [ ] Single-end inputs
- [ ] Paired-end inputs
- [ ] Interleaved inputs
- [ ] Multiple input files
- [ ] Different file formats (FASTQ, BAM, etc.)

### 2. Feature Scenarios

Test all module features:

- [ ] Default behavior
- [ ] Optional features enabled
- [ ] Optional features disabled
- [ ] Custom prefixes
- [ ] Different parameter combinations

### 3. Edge Cases

Test edge cases:

- [ ] Empty optional inputs
- [ ] Special characters in filenames
- [ ] Very small files
- [ ] Expected failures (missing required inputs)

### 4. Configuration Variants

Test different configurations:

- [ ] Default configuration
- [ ] Custom configuration files
- [ ] Different parameter sets
- [ ] Tool-specific modes (e.g., arriba, starfusion)

### 5. Example Test Scenarios

```groovy
// Basic functionality
test("sarscov2 single-end [fastq]") { ... }
test("sarscov2 paired-end [fastq]") { ... }
test("sarscov2 interleaved [fastq]") { ... }

// Different file types
test("sarscov2 paired-end [bam]") { ... }

// Multiple files
test("sarscov2 multiple [fastq]") { ... }

// Custom options
test("sarscov2 custom_prefix") { ... }
test("test_fastp_single_end_trim_fail") { ... }
test("test_fastp_paired_end_merged") { ... }

// Configuration variants
test("homo_sapiens - paired_end - arriba") { ... }
test("homo_sapiens - paired_end - starfusion") { ... }
```

---

## Stub Testing

### 1. Stub Test Structure

Always create stub versions of real tests:

```groovy
test("test_name - stub") {
    options "-stub"
    
    when {
        process {
            """
            // Same inputs as real test
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
```

### 2. Stub Test Coverage

Create stub tests for:

- [ ] All real test scenarios
- [ ] Single-end inputs
- [ ] Paired-end inputs
- [ ] All configuration variants
- [ ] All feature combinations

### 3. Stub Test Assertions

Stub tests typically only check:

```groovy
then {
    assertAll (
        { assert process.success },
        { assert snapshot(process.out).match() }
    )
}
```

**Note:** Stub tests don't validate file contents, only output structure.

---

## Setup Blocks for Dependencies

### 1. Basic Setup

Run dependent processes before the main test:

```groovy
test("test_name") {
    setup {
        run("DEPENDENT_PROCESS") {
            script "../../../tool/process/main.nf"
            process {
                """
                input[0] = channel.of([...])
                input[1] = channel.of([...])
                """
            }
        }
    }

    when {
        process {
            """
            input[0] = channel.of([...])
            input[1] = DEPENDENT_PROCESS.out.output_name
            """
        }
    }
    // ...
}
```

### 2. Multiple Dependencies

```groovy
setup {
    run("PROCESS_1") {
        script "../../../tool1/process1/main.nf"
        process {
            """
            input[0] = channel.of([...])
            """
        }
    }
    run("PROCESS_2") {
        script "../../../tool2/process2/main.nf"
        process {
            """
            input[0] = PROCESS_1.out.output
            """
        }
    }
}
```

### 3. Using Aliases for Processes

When you need to use the same process multiple times with different configurations, or when the process name doesn't clearly indicate its purpose in the test context, use aliases:

```groovy
setup {
    // Run the same process with an alias to distinguish its purpose
    run("SORTMERNA", alias: "SORTMERNA_INDEX") {
        script "../main.nf"
        process {
            """
            input[0] = channel.of([[],[]])
            input[1] = channel.of([
                [ id: 'test2' ],
                [ file(params.modules_testdata_base_path + 'genomics/sarscov2/genome/genome.fasta', checkIfExists: true) ]
            ])
            input[2] = channel.of([[],[]])
            """
        }
    }
}

when {
    process {
        """
        input[0] = channel.of([...])
        input[1] = channel.of([...])
        // Reference the aliased process output
        input[2] = SORTMERNA_INDEX.out.index
        """
    }
}
```

**Use cases for aliases:**

1. **Same process, different purpose:**

   ```groovy
   setup {
       // First run: indexing only
       run("SORTMERNA", alias: "SORTMERNA_INDEX") {
           // Indexing configuration
       }
       // Second run: alignment using the index
       run("SORTMERNA", alias: "SORTMERNA_ALIGN") {
           // Alignment configuration
           // input[2] = SORTMERNA_INDEX.out.index
       }
   }
   ```

2. **Clarifying process purpose:**

   ```groovy
   setup {
       // Alias makes it clear this is for indexing
       run("STAR_GENOMEGENERATE", alias: "STAR_INDEX") {
           // ...
       }
   }
   ```

3. **Multiple instances of the same process:**

   ```groovy
   setup {
       run("TOOL_PROCESS", alias: "TOOL_PROCESS_REFERENCE") {
           // Process reference data
       }
       run("TOOL_PROCESS", alias: "TOOL_PROCESS_SAMPLE") {
           // Process sample data
           // Can use TOOL_PROCESS_REFERENCE.out if needed
       }
   }
   ```

### 4. Using Setup Outputs

Reference setup outputs in the main test:

```groovy
when {
    process {
        """
        input[0] = channel.of([...])
        input[1] = STAR_GENOMEGENERATE.out.index
        input[2] = channel.of([...])
        """
    }
}
```

### 4. Setup in Stub Tests

Include setup in stub tests if dependencies are needed:

```groovy
test("test_name - stub") {
    options "-stub"
    
    setup {
        run("DEPENDENT_PROCESS") {
            // ...
        }
    }
    // ...
}
```

---

## Advanced Patterns

### 1. Testing with Parameters

Override parameters in tests:

```groovy
when {
    params {
        outdir = "$outputDir"
        custom_param = "value"
    }
    process {
        """
        // ...
        """
    }
}
```

### 2. Testing Optional Outputs

Validate optional outputs conditionally:

```groovy
then {
    assertAll (
        { assert process.success },
        { assert process.out.required_output[0][1] ==~ ".*/expected.*" },
        { assert process.out.optional_output == [] || process.out.optional_output[0][1].exists() }
    )
}
```

### 3. Testing File Content Patterns

Validate specific content patterns:

```groovy
{ assert path(process.out.html[0][1]).text.contains("expected_text") }
{ assert path(process.out.log[0][1]).text.matches(".*pattern.*") }
```

### 4. Testing Multiple Output Channels

Validate all output channels:

```groovy
then {
    assertAll (
        { assert process.success },
        { assert process.out.html[0][1] ==~ ".*/test_fastqc.html" },
        { assert process.out.zip[0][1] ==~ ".*/test_fastqc.zip" },
        { assert process.out.versions.exists() }
    )
}
```

### 5. Testing with Different Configs

Test same scenario with different configurations:

```groovy
test("test_name_default") {
    config "./nextflow.config"
    // ...
}

test("test_name_custom") {
    config "./nextflow.custom.config"
    // ...
}
```

### 6. Testing Channel Transformations

Test with transformed channels:

```groovy
when {
    process {
        """
        input[0] = channel.of([...])
            .map { meta, data -> [meta + [processed: true], data] }
        """
    }
}
```

---

## Common Pitfalls

### 1. Missing Metadata

**Wrong:**

```groovy
input[0] = channel.of([
    file(params.modules_testdata_base_path + 'file.fastq.gz', checkIfExists: true)
])
```

**Correct:**

```groovy
input[0] = channel.of([
    [ id: 'test', single_end: true ],  // Always include metadata
    file(params.modules_testdata_base_path + 'file.fastq.gz', checkIfExists: true)
])
```

### 2. Incorrect Output Path Access

**Wrong:**

```groovy
{ assert process.out.output[0] ==~ ".*/expected.*" }
```

**Correct:**

```groovy
{ assert process.out.output[0][1] ==~ ".*/expected.*" }  // [0] = tuple, [1] = file
```

### 3. Missing checkIfExists

**Wrong:**

```groovy
file(params.modules_testdata_base_path + 'file.fastq.gz')
```

**Correct:**

```groovy
file(params.modules_testdata_base_path + 'file.fastq.gz', checkIfExists: true)
```

### 4. Incorrect Snapshot Usage

**Wrong:**

```groovy
{ assert snapshot(process.out.output[0][1]).match() }  // Snapshotting file path
```

**Correct:**

```groovy
{ assert snapshot(process.out.output).match() }  // Snapshot channel structure
{ assert snapshot(file(process.out.output[0][1]).name, process.out.versions).match() }  // Snapshot file name
```

### 5. Missing Stub Tests

Always create stub versions:

```groovy
test("test_name") { ... }
test("test_name - stub") {
    options "-stub"
    // ...
}
```

### 6. Hardcoded Paths

**Wrong:**

```groovy
file('/absolute/path/to/file.fastq.gz')
```

**Correct:**

```groovy
file(params.modules_testdata_base_path + 'relative/path/file.fastq.gz', checkIfExists: true)
```

### 7. Incomplete Assertions

**Wrong:**

```groovy
then {
    assert process.success  // Missing assertAll
}
```

**Correct:**

```groovy
then {
    assertAll (
        { assert process.success },
        { assert process.out.output[0][1] ==~ ".*/expected.*" }
    )
}
```

### 8. Missing Version Snapshot

Always snapshot versions:

```groovy
{ assert snapshot(process.out.versions).match() }
```

---

## Complete Example

### Example: FastQC Test File

```groovy
nextflow_process {

    name "Test Process FASTQC"
    script "../main.nf"
    process "FASTQC"

    tag "modules"
    tag "modules_nfcore"
    tag "fastqc"

    test("sarscov2 single-end [fastq]") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: true ],
                    [ file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true) ]
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.html[0][1] ==~ ".*/test_fastqc.html" },
                { assert process.out.zip[0][1] ==~ ".*/test_fastqc.zip" },
                { assert path(process.out.html[0][1]).text.contains("<tr><td>File type</td><td>Conventional base calls</td></tr>") },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("sarscov2 paired-end [fastq]") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: false ],
                    [
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true),
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_2.fastq.gz', checkIfExists: true)
                    ]
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.html[0][1][0] ==~ ".*/test_1_fastqc.html" },
                { assert process.out.html[0][1][1] ==~ ".*/test_2_fastqc.html" },
                { assert process.out.zip[0][1][0] ==~ ".*/test_1_fastqc.zip" },
                { assert process.out.zip[0][1][1] ==~ ".*/test_2_fastqc.zip" },
                { assert path(process.out.html[0][1][0]).text.contains("<tr><td>File type</td><td>Conventional base calls</td></tr>") },
                { assert path(process.out.html[0][1][1]).text.contains("<tr><td>File type</td><td>Conventional base calls</td></tr>") },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("sarscov2 custom_prefix") {
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'mysample', single_end: true ],
                    [ file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true) ]
                ])
                """
            }
        }

        then {
            assertAll (
                { assert process.success },
                { assert process.out.html[0][1] ==~ ".*/mysample_fastqc.html" },
                { assert process.out.zip[0][1] ==~ ".*/mysample_fastqc.zip" },
                { assert snapshot(process.out.versions).match() }
            )
        }
    }

    test("sarscov2 single-end [fastq] - stub") {
        options "-stub"
        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: true ],
                    [ file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true) ]
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

### Example: Complex Test with Setup

```groovy
nextflow_process {

    name "Test Process STAR_ALIGN"
    script "../main.nf"
    process "STAR_ALIGN"
    tag "modules"
    tag "modules_nfcore"
    tag "star"
    tag "star/align"

    test("homo_sapiens - paired_end") {
        config "./nextflow.config"

        setup {
            run("STAR_GENOMEGENERATE") {
                script "../../../star/genomegenerate/main.nf"
                process {
                    """
                    input[0] = channel.of([
                        [ id: 'test_fasta' ],
                        [ file(params.modules_testdata_base_path + 'genomics/homo_sapiens/genome/genome.fasta', checkIfExists: true) ]
                    ])
                    input[1] = channel.of([
                        [ id: 'test_gtf' ],
                        [ file(params.modules_testdata_base_path + 'genomics/homo_sapiens/genome/genome.gtf', checkIfExists: true) ]
                    ])
                    """
                }
            }
        }

        when {
            process {
                """
                input[0] = channel.of([
                    [ id: 'test', single_end: false ],
                    [
                        file(params.modules_testdata_base_path + 'genomics/homo_sapiens/illumina/fastq/test_rnaseq_1.fastq.gz', checkIfExists: true),
                        file(params.modules_testdata_base_path + 'genomics/homo_sapiens/illumina/fastq/test_rnaseq_2.fastq.gz', checkIfExists: true)
                    ]
                ])
                input[1] = STAR_GENOMEGENERATE.out.index
                input[2] = channel.of([
                    [ id: 'test_gtf' ],
                    [ file(params.modules_testdata_base_path + 'genomics/homo_sapiens/genome/genome.gtf', checkIfExists: true) ]
                ])
                input[3] = false
                input[4] = 'illumina'
                input[5] = false
                """
            }
        }

        then {
            assertAll(
                { assert process.success },
                { assert snapshot(
                    file(process.out.log_final[0][1]).name,
                    file(process.out.log_out[0][1]).name,
                    bam(process.out.bam[0][1]).getReadsMD5(),
                    process.out.versions
                ).match() }
            )
        }
    }
}
```

---

## Summary Checklist

When writing nf-test test files:

### Structure

- [ ] Test file in `tests/main.nf.test`
- [ ] Correct `name`, `script`, and `process` declarations
- [ ] Appropriate tags for organization

### Test Coverage

- [ ] Single-end input test
- [ ] Paired-end input test
- [ ] Interleaved input test (if applicable)
- [ ] Multiple file test (if applicable)
- [ ] Custom prefix test
- [ ] Feature-specific tests
- [ ] Configuration variant tests
- [ ] Stub versions of all real tests

### Input Setup

- [ ] Metadata included in all inputs
- [ ] `checkIfExists: true` for all file references
- [ ] Correct channel structure matching module inputs
- [ ] Optional inputs handled correctly

### Assertions

- [ ] `assert process.success` in all tests
- [ ] Output file pattern matching
- [ ] File content validation (where appropriate)
- [ ] Empty output validation (for optional outputs)
- [ ] Version snapshot in all real tests

### Configuration

- [ ] `tests/nextflow.config` created
- [ ] Variant configs for different scenarios
- [ ] Parameter overrides when needed

### Best Practices

- [ ] Descriptive test names
- [ ] Consistent naming patterns
- [ ] Comments for complex setups
- [ ] Setup blocks for dependencies
- [ ] Snapshot testing for versions and outputs

---

## References

- [nf-test Documentation](https://code.askimed.com/nf-test/)
- [nf-core Module Testing Guidelines](https://nf-co.re/docs/contributing/modules_testing)
- [Nextflow Process Documentation](https://www.nextflow.io/docs/latest/process.html)
- Example test files: `modules/nf-core/*/tests/main.nf.test`
