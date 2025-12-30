---
layout: post
title: "Groovy Reference for Nextflow Pipeline Development"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, groovy, programming, bioinformatics, workflows, reference]
author: Haibo Liu, PhD
toc: true
---

# Groovy Reference for Nextflow Pipeline Development

This guide provides essential Groovy syntax and examples specifically tailored for building sophisticated Nextflow pipelines. It focuses on the most commonly used Groovy features in Nextflow workflows.

## Table of Contents

1. [Basic Syntax](#basic-syntax)
2. [Data Types and Variables](#data-types-and-variables)
3. [Collections (Lists and Maps)](#collections-ranges-lists-and-maps)
4. [Strings and String Interpolation](#strings-and-string-interpolation)
5. [Closures](#closures)
6. [Conditional Logic](#conditional-logic)
7. [Loops and Iteration](#loops-and-iteration)
8. [File Operations](#file-operations)
9. [Regular Expressions](#regular-expressions)
10. [Error Handling](#error-handling)
11. [Common Patterns in Nextflow Workflows](#common-patterns-in-nextflow-workflows)

---

## Basic Syntax

### Comments

```groovy
// Single-line comment

/*
 * Multi-line comment
 */

/**
 * Documentation comment
 */
```

### Variable Declaration

```groovy
// Dynamic typing (most common in Nextflow)
def sample = 'sample1'
def count = 42
def isActive = true

// Explicit typing (optional, but useful for clarity)
String sampleName = 'sample1'
Integer readCount = 1000000
Boolean skipStep = false

// Multiple assignment
def (id, path) = ['sample1', '/path/to/file.fq']
```

**When to use `def`:**

- **Required**: When declaring variables in scripts or closures without explicit type
- **Required**: For multiple assignment: `def (a, b) = [1, 2]`
- **Required**: When the variable type cannot be inferred from context
- **Optional**: Can be omitted when type is explicit: `String name = 'value'` (but `def` is still valid)
- **In Nextflow**: `def` is commonly used for local variables in workflow scripts and closures

**Variable Scope in Nextflow Module Script Sections:**

In Nextflow module `script:` blocks, variables declared with `def` have specific scoping rules:

```groovy
process EXAMPLE {
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    // Variables declared with 'def' are local to the script block
    def sample_name = input_file.baseName
    def output_path = "${sample_name}_processed.txt"
    
    // These variables are only accessible within this script block
    // They are NOT accessible in other sections (input, output, etc.)
    
    """
    echo "Processing ${sample_name}"
    process_file ${input_file} > ${output_path}
    """
}

// In workflow context (outside process)
workflow {
    // Variables declared here are in workflow scope
    def workflow_var = 'value'
    
    // Variables from process script blocks are NOT accessible here
    // EXAMPLE.sample_name  // ERROR: not accessible
}
```

**Key Points:**

1. **Script Block Scope**: Variables declared with `def` in a `script:` block are local to that block only
2. **Not Accessible in Other Sections**: Script variables cannot be accessed in `input:`, `output:`, `when:`, or other process sections
3. **Shell Script Access**: Variables can be accessed in the shell script using `${variable}` syntax
4. **Workflow Scope**: Variables in workflow blocks are separate from process script variables
5. **Closure Scope**: In closures (like `.map {}`), `def` variables are local to the closure

**Variable Scope WITHOUT `def` (Bare Assignment):**

In contrast, variables declared without `def` have different scoping rules:

```groovy
process EXAMPLE {
    input:
    path input_file
    
    script:
    // WITHOUT 'def' - creates a property/binding variable
    // IMPORTANT: Variables without 'def' are accessible across ALL sections
    sample_name = input_file.baseName  // No 'def'
    output_path = "${sample_name}_processed.txt"
    
    // These variables are accessible in:
    // - The script block (shell script)
    // - The output section
    // - The when section
    // - Any other section of the process
    
    """
    echo "Processing ${sample_name}"
    process_file ${input_file} > ${output_path}
    """
    
    output:
    // sample_name and output_path ARE accessible here (unlike with 'def')
    path output_path, emit: result
}
```

**Critical Difference:**

- **WITH `def`**: Variables are local to the section where they're declared (script block only)
- **WITHOUT `def`**: Variables are accessible across ALL sections of the module (input, output, script, when, etc.)

```groovy
// In workflow context
workflow {
    // WITHOUT 'def' - creates a property on the workflow object
    workflow_var = 'value'  // No 'def'
    
    // This creates a property that can be accessed elsewhere
    // but behavior may differ from 'def' variables
}
```

**Key Differences:**

1. **Module Scope**: Variables without `def` are accessible across ALL sections of a process (input, output, script, when, etc.), unlike `def` variables which are local to their section
2. **Script Block**: Variables without `def` in script blocks are accessible in output sections and other process sections
3. **Workflow Block**: Variables without `def` in workflows can create properties on the workflow object, potentially accessible in different scopes
4. **Closures**: Variables without `def` in closures may bind to outer scope differently than `def` variables
5. **Best Practice**: Use `def` for local variables to avoid unintended cross-section access; use bare assignment only when you need cross-section access

**Examples:**

```groovy
// In script block - DIFFERENT scoping behavior
process PROCESS {
    input:
    path input_file
    
    script:
    def with_def = 'value1'      // Local to script block ONLY
    without_def = 'value2'       // Accessible in ALL sections
    
    """
    echo "${with_def}"      // Works
    echo "${without_def}"   // Works
    """
    
    output:
    // with_def is NOT accessible here (ERROR)
    // path "${with_def}_output.txt"  // ERROR: with_def not in scope
    
    // without_def IS accessible here
    path "${without_def}_output.txt", emit: result  // Works!
}

// In workflow - different behavior
workflow {
    def local_var = 'local'      // Local to workflow block
    global_prop = 'global'        // Creates property (avoid in Nextflow)
    
    // local_var is only accessible in this workflow block
    // global_prop might be accessible in unexpected places (not recommended)
}

// In closures - binding differences
def outer_var = 'outer'

channel
    .of('item1', 'item2')
    .map { item ->
        def local = 'local'           // Local to closure
        closure_var = 'closure'       // May bind differently
        
        // Both accessible, but 'def' is clearer
        "${outer_var}_${item}_${local}"
    }
```

**Recommendations:**

- **Always use `def`** in script blocks for clarity and explicit local scope except the variable is needed in other sections, such as "prefix".
- **Always use `def`** in workflow blocks to avoid creating unexpected properties
- **Always use `def`** in closures to ensure local scope
- **Avoid bare assignment** (without `def`) as it can lead to unexpected scoping behavior

**Examples:**

```groovy
process PROCESS {
    input:
    path input_file
    
    script:
    // Local to script block
    def base_name = input_file.baseName
    def output_name = "${base_name}_out.txt"
    
    // Accessible in shell script
    """
    echo "Base name: ${base_name}"
    tool --input ${input_file} --output ${output_name}
    """
    
    // base_name is NOT accessible here
    // output:
    //     path "${base_name}_out.txt"  // ERROR: base_name not in scope
}

// In channel operations
channel
    .fromPath('/data/*.fastq.gz')
    .map { file ->
        // 'def' creates local variable in closure scope
        def sample_id = file.baseName
        def meta = [id: sample_id, file: file]
        [meta, file]
    }
```

**Best Practices:**

- Use `def` for local variables within script blocks
- Use `${variable}` to access Groovy variables in shell scripts
- Avoid trying to access script variables in other process sections
- Use `task.ext.prefix` or similar for values needed in multiple sections

**Example: Using `task.ext.prefix` for Cross-Section Access:**

When you need a value in both the script and output sections, use `task.ext` properties set in `modules.config`:

```groovy
// In modules.config
process {
    withName: 'MY_PROCESS' {
        ext.prefix = { "${meta.id}_processed" }
    }
}

// In module main.nf
process MY_PROCESS {
    input:
    tuple val(meta), path(input_file)
    
    output:
    // task.ext.prefix is accessible here
    path "${task.ext.prefix}.bam", emit: bam
    path "${task.ext.prefix}.bai", emit: bai
    
    script:
    // task.ext.prefix is also accessible here
    def prefix = task.ext.prefix
    
    """
    tool \\
        --input ${input_file} \\
        --output ${prefix}.bam \\
        --index ${prefix}.bai
    """
}
```

**Alternative: Using Variables Without `def` (When Appropriate):**

If you need a computed value in multiple sections and don't want to use `task.ext`, you can use a variable without `def`:

```groovy
process MY_PROCESS {
    input:
    tuple val(meta), path(input_file)
    
    script:
    // Without 'def' - accessible in all sections
    prefix = "${meta.id}_processed"
    
    """
    tool --input ${input_file} --output ${prefix}.bam
    """
    
    output:
    // prefix is accessible here because it was declared without 'def'
    path "${prefix}.bam", emit: bam
    path "${prefix}.bai", emit: bai
}
```

**When to Use Each Approach:**

- **`task.ext.prefix`**: Recommended for values that should be configurable in `modules.config` or when following nf-core conventions
- **Variable without `def`**: Use when you need a computed value in multiple sections and don't need external configuration
- **Variable with `def`**: Use for local variables that are only needed within the script block

**Examples:**

```groovy
// def required - no explicit type
def sample = 'sample1'

// def optional - explicit type provided
String sample = 'sample1'  // def not needed
def String sample = 'sample1'  // def optional but redundant

// def required - multiple assignment
def (id, path) = ['sample1', '/path/to/file.fq']

// def required - in closures when type is dynamic
channel.map { def item -> item.toUpperCase() }

// def optional - can infer type from assignment
def count = 42  // Integer inferred
Integer count = 42  // def not needed
```

### Operators

```groovy
// Arithmetic
def sum = 10 + 5
def product = 3 * 4
def quotient = 15 / 3
def remainder = 10 % 3
def power = 2 ** 8  // 256

// Comparison
def isEqual = (a == b)
def notEqual = (a != b)
def greater = (a > b)
def lessOrEqual = (a <= b)

// Logical
def result = (condition1 && condition2)
def result = (condition1 || condition2)
def result = !condition

// Null-safe navigation
def value = object?.property?.subProperty  // Returns null if any part is null

// Ternary conditional operator (if-else shorthand)
def result = condition ? valueIfTrue : valueIfFalse
def type = params.single_end ? 'single' : 'paired'
def output = file.exists() ? file : createDefaultFile()

// Elvis operator (default value when null/false)
// Returns left side if truthy, otherwise returns right side
def name = params.name ?: 'default_name'  // If params.name is null/false, use 'default_name'
def count = params.count ?: 0              // If params.count is null/false, use 0
def threads = params.threads ?: 1          // If params.threads is null/false, use 1

// Elvis operator with method calls
def file = params.input ?: file('default.txt')
def value = map?.key ?: 'default'

// Combined null-safe and Elvis
def result = object?.property?.subProperty ?: 'default'
def path = params.output_dir ?: "${workflow.projectDir}/output"
```

**Ternary Operator vs Elvis Operator:**

- **Ternary (`? :`)**: Full conditional - `condition ? valueIfTrue : valueIfFalse`
  - Evaluates any boolean condition
  - Returns one of two values based on condition
  - Example: `params.single_end ? 'single' : 'paired'`

- **Elvis (`?:`)**: Null/truthy check - `value ?: defaultValue`
  - Checks if left side is truthy (not null, not false, not empty)
  - Returns left side if truthy, otherwise returns right side
  - Shorthand for: `value != null && value != false ? value : defaultValue`
  - Example: `params.name ?: 'default'`

**Common Use Cases:**

```groovy
// Ternary: Choose between two values based on condition
def file_type = params.single_end ? 'single' : 'paired'
def aligner = params.aligner == 'star' ? 'STAR' : 'HISAT2'
def output = count > 0 ? "Found ${count}" : "Not found"

// Elvis: Provide default when value is null/false/empty
def threads = params.threads ?: 1
def outdir = params.outdir ?: './results'
def genome = params.genome ?: 'GRCh38'

// Elvis with collections
def samples = params.samples ?: []
def config = params.config ?: [:]

// Elvis with method results
def file = findFile() ?: createDefaultFile()
def value = computeValue() ?: 0

// Nested usage
def result = condition1 ? value1 : (condition2 ? value2 : defaultValue)
def path = params.custom_path ?: (params.default_path ?: '/default')
```

### Spread Operator (`*`)

The spread operator expands collections into individual elements.

```groovy
// Spread in method calls
def list = [1, 2, 3]
def max = Math.max(*list)  // Equivalent to Math.max(1, 2, 3)

// Spread in list construction
def list1 = [1, 2, 3]
def list2 = [4, 5, 6]
def combined = [*list1, *list2]  // [1, 2, 3, 4, 5, 6]
def withExtra = [0, *list1, 4]   // [0, 1, 2, 3, 4]

// Spread in map construction
def map1 = [a: 1, b: 2]
def map2 = [c: 3, d: 4]
def combined = [*:map1, *:map2]  // [a: 1, b: 2, c: 3, d: 4]
def withExtra = [*:map1, e: 5]   // [a: 1, b: 2, e: 5]

// Spread in function arguments
def processItems(item1, item2, item3) {
    // Process items
}
def items = ['a', 'b', 'c']
processItems(*items)  // Equivalent to processItems('a', 'b', 'c')

// Spread with ranges
def range = 1..5
def list = [*range]  // [1, 2, 3, 4, 5]
```

**Use Cases in Nextflow:**

```groovy
// Combine multiple lists
def samples1 = ['s1', 's2']
def samples2 = ['s3', 's4']
def all_samples = [*samples1, *samples2]  // ['s1', 's2', 's3', 's4']

// Merge metadata maps
def meta1 = [id: 's1', type: 'riboseq']
def meta2 = [condition: 'control', replicate: 1]
def merged = [*:meta1, *:meta2]  // [id: 's1', type: 'riboseq', condition: 'control', replicate: 1]

// Pass list elements as arguments
def files = ['file1.fq', 'file2.fq', 'file3.fq']
def result = processFiles(*files)  // processFiles('file1.fq', 'file2.fq', 'file3.fq')
```

### Spread-Dot Operator (`*.`)

The spread-dot operator applies a method or property access to each element of a collection.

```groovy
// Apply method to each element
def files = [file1, file2, file3]
def names = files*.name           // [file1.name, file2.name, file3.name]
def sizes = files*.size()         // [file1.size(), file2.size(), file3.size()]

// Apply property access
def samples = [
    [id: 's1', type: 'riboseq'],
    [id: 's2', type: 'rnaseq'],
    [id: 's3', type: 'riboseq']
]
def ids = samples*.id             // ['s1', 's2', 's3']
def types = samples*.type          // ['riboseq', 'rnaseq', 'riboseq']

// Nested spread-dot
def nested = [
    [files: [file1, file2]],
    [files: [file3, file4]]
]
def allFiles = nested*.files      // [[file1, file2], [file3, file4]]
def flatFiles = nested*.files.flatten()  // [file1, file2, file3, file4]

// Safe navigation with spread-dot
def items = [obj1, obj2, null, obj4]
def values = items?*.property     // [obj1.property, obj2.property, null, obj4.property]
```

**Use Cases in Nextflow:**

```groovy
// Extract properties from list of maps
def samples = [
    [id: 's1', file: '/path/to/s1.fq'],
    [id: 's2', file: '/path/to/s2.fq']
]
def sample_ids = samples*.id      // ['s1', 's2']
def files = samples*.file          // ['/path/to/s1.fq', '/path/to/s2.fq']

// Extract file properties
def file_list = [file1, file2, file3]
def names = file_list*.name       // ['file1.fq', 'file2.fq', 'file3.fq']
def baseNames = file_list*.baseName  // ['file1', 'file2', 'file3']

// Transform with method calls
def numbers = [1, 2, 3, 4, 5]
def doubled = numbers*.multiply(2)  // [2, 4, 6, 8, 10] (if multiply method exists)
def strings = numbers*.toString()   // ['1', '2', '3', '4', '5']

// Safe navigation (handles nulls)
def items = [obj1, null, obj3]
def values = items?*.property      // [obj1.property, null, obj3.property]
```

**Comparison: Spread vs Spread-Dot:**

```groovy
// Spread (*) - Expands collection
def list = [1, 2, 3]
def combined = [0, *list, 4]      // [0, 1, 2, 3, 4] - expands elements

// Spread-dot (*.) - Applies operation to each element
def files = [file1, file2, file3]
def names = files*.name            // [file1.name, file2.name, file3.name] - applies .name
```

### Safe Navigation Operator (`?.`)

Safely accesses properties/methods, returning null if object is null.

```groovy
// Safe property access
def value = object?.property       // null if object is null, otherwise object.property
def nested = object?.property?.subProperty  // Safe chaining

// Safe method call
def result = object?.method()      // null if object is null, otherwise method result
def result = object?.method()?.property  // Safe chaining

// Safe indexing
def item = list?[0]                // null if list is null, otherwise list[0]
```

**Examples:**

```groovy
// Handle potentially null objects
def file = params.input ? file(params.input) : null
def name = file?.name              // null if file is null
def size = file?.size()            // null if file is null

// Safe chaining
def path = config?.input?.file?.path  // Returns null if any part is null

// Safe with collections
def samples = params.samples ?: []
def first_id = samples?[0]?.id    // Safe access to first element's id
```

### Method Pointer Operator (`.&`)

Creates a method reference (closure) from a method.

```groovy
// Create method reference
def list = ['a', 'B', 'c']
def toUpper = String.&toUpperCase
def upper = list.collect(toUpper)  // ['A', 'B', 'C']

// Equivalent to
def upper = list.collect { it.toUpperCase() }

// With instance method
def file = new File('/path/to/file.txt')
def getName = file.&getName
def name = getName()               // 'file.txt'
```

### Field Access Operator (`.@`)

Direct field access (bypasses getter methods).

```groovy
// Direct field access
class Example {
    def field = 'value'
    def getField() { 'getter_value' }
}

def obj = new Example()
def value1 = obj.field              // 'getter_value' (uses getter)
def value2 = obj.@field            // 'value' (direct field access)
```

### Spaceship Operator (`<=>`)

Three-way comparison operator.

```groovy
// Returns: -1 (less), 0 (equal), 1 (greater)
def result = a <=> b

// Common use in sorting
def numbers = [3, 1, 4, 1, 5]
def sorted = numbers.sort { a, b -> a <=> b }  // [1, 1, 3, 4, 5]
def desc = numbers.sort { a, b -> b <=> a }    // [5, 4, 3, 1, 1]

// With custom objects
def samples = [
    [id: 's1', count: 100],
    [id: 's2', count: 50],
    [id: 's3', count: 200]
]
def sorted = samples.sort { a, b -> a.count <=> b.count }
```

### Identity Operator (`===` and `!==`)

Reference equality (not value equality).

```groovy
// Identity (same object reference)
def a = [1, 2, 3]
def b = [1, 2, 3]
def c = a

a == b    // true (value equality)
a === b   // false (different objects)
a === c   // true (same object reference)

a != b    // false
a !== b   // true
```

### Regex Match Operators

```groovy
// Find operator (=~) - returns Matcher
def matcher = text =~ /pattern/
if (matcher) { /* match found */ }

// Match operator (==~) - returns boolean (exact match)
def exact = text ==~ /pattern/  // true if entire string matches

// Pattern operator (~) - creates Pattern
def pattern = ~/pattern/
```

---

## Data Types and Variables

### Basic Types

```groovy
// String
def text = "Hello"
def text = 'World'
def multiline = """
    Line 1
    Line 2
"""

// Numbers
def integer = 42
def decimal = 3.14
def bigDecimal = 123.456789G

// Boolean
def flag = true
def flag = false

// Null
def value = null
```

### Type Checking

```groovy
// Check type
if (value instanceof String) {
    // Handle string
}

if (value instanceof List) {
    // Handle list
}

if (value instanceof Map) {
    // Handle map
}

if (value instanceof Path) {
    // Handle file path
}
// Type casting
def number = "42" as Integer
def list = value as List
```

---

## Data Type Conversion

Groovy provides multiple ways to convert between data types, which is essential for Nextflow pipeline development.

### String Conversions

```groovy
// String to Number
def str = "42"
def int_val = str as Integer        // 42
def int_val = str.toInteger()      // 42
def int_val = Integer.parseInt(str) // 42

def str = "3.14"
def float_val = str as Float        // 3.14
def float_val = str.toFloat()      // 3.14
def double_val = str as Double      // 3.14
def double_val = str.toDouble()    // 3.14

def str = "123456789"
def long_val = str as Long          // 123456789L
def long_val = str.toLong()        // 123456789L

// Number to String
def num = 42
def str = num.toString()            // "42"
def str = String.valueOf(num)       // "42"
def str = "${num}"                  // "42" (interpolation)

def float_num = 3.14
def str = float_num.toString()      // "3.14"
def str = String.format("%.2f", float_num)  // "3.14" (formatted)

// Boolean to String
def bool = true
def str = bool.toString()           // "true"
def str = "${bool}"                 // "true"
```

### Number Conversions

```groovy
// Integer conversions
def int_val = 42
def long_val = int_val as Long      // 42L
def float_val = int_val as Float    // 42.0
def double_val = int_val as Double  // 42.0
def string_val = int_val.toString() // "42"

// Float/Double conversions
def float_val = 3.14F
def int_val = float_val as Integer  // 3 (truncates)
def int_val = float_val.intValue()  // 3
def double_val = float_val as Double // 3.14
def string_val = float_val.toString() // "3.14"

// Rounding
def float_val = 3.7F
def rounded = Math.round(float_val)  // 4
def rounded = float_val.round()      // 4
def floor = Math.floor(float_val)    // 3.0
def ceil = Math.ceil(float_val)      // 4.0
```

### Collection Conversions

```groovy
// List to Array
def list = [1, 2, 3, 4, 5]
def array = list as int[]           // int array
def array = list.toArray()          // Object array
def array = list as String[]         // String array (if elements are strings)

// Array to List
def array = [1, 2, 3] as int[]
def list = array.toList()           // [1, 2, 3]
def list = array as List            // [1, 2, 3]

// Set to List
def set = [1, 2, 3] as Set
def list = set.toList()             // [1, 2, 3]
def list = set as List              // [1, 2, 3]

// List to Set
def list = [1, 2, 2, 3, 3]
def set = list as Set               // [1, 2, 3] (removes duplicates)
def set = list.toSet()              // [1, 2, 3]

// Map to List
def map = [a: 1, b: 2, c: 3]
def keys = map.keySet().toList()    // ['a', 'b', 'c']
def values = map.values().toList()  // [1, 2, 3]
def entries = map.entrySet().toList() // [a=1, b=2, c=3]
```

### Boolean Conversions

```groovy
// String to Boolean
def str = "true"
def bool = str.toBoolean()          // true
def bool = Boolean.parseBoolean(str) // true

def str = "false"
def bool = str.toBoolean()          // false

// Number to Boolean (truthy/falsy)
def num = 1
def bool = num as Boolean           // true (non-zero is true)
def num = 0
def bool = num as Boolean           // false

// Collection to Boolean
def list = [1, 2, 3]
def bool = list as Boolean          // true (non-empty is true)
def list = []
def bool = list as Boolean          // false (empty is false)

// String to Boolean (explicit)
def str = "yes"
def bool = str == "true" || str == "yes" || str == "1"
```

### Boolean to Shell-Compatible Values (for Triple-Quoted Scripts)

In triple-quoted script sections (shell scripts), Groovy booleans need to be converted to shell-compatible values for conditional tests:

```groovy
process EXAMPLE {
    input:
    val(flag)
    
    script:
    def bool = flag  // Groovy boolean
    
    // Convert to shell-compatible boolean values
    def shell_bool = bool ? "true" : "false"      // String "true"/"false"
    def shell_flag = bool ? "1" : "0"            // Numeric 1/0
    def shell_yesno = bool ? "yes" : "no"         // String "yes"/"no"
    def shell_onoff = bool ? "on" : "off"         // String "on"/"off"
    
    """
    # Using in shell conditionals
    if [ "${shell_bool}" = "true" ]; then
        echo "Flag is true"
    fi
    
    # Using numeric test
    if [ ${shell_flag} -eq 1 ]; then
        echo "Flag is set"
    fi
    
    # Using in command flags
    tool ${bool ? '--enable' : '--disable'} feature
    tool --flag ${shell_bool}
    """
}
```

**Common Patterns:**

```groovy
// Pattern 1: Conditional flag presence
def verbose = params.verbose ?: false
def verbose_flag = verbose ? "--verbose" : ""

"""
tool ${verbose_flag} --input file.txt
"""

// Pattern 2: Boolean to numeric (for exit codes, counts)
def success = true
def exit_code = success ? 0 : 1
def count = success ? 1 : 0

"""
command || exit ${exit_code}
"""

// Pattern 3: Boolean to yes/no string
def confirm = params.confirm ?: false
def yes_no = confirm ? "yes" : "no"

"""
echo "${yes_no}" | interactive_tool
"""

// Pattern 4: Multiple boolean flags
def flag1 = params.flag1 ?: false
def flag2 = params.flag2 ?: false

def flags = []
if (flag1) flags << "--flag1"
if (flag2) flags << "--flag2"
def flags_str = flags.join(' ')

"""
tool ${flags_str} --input file.txt
"""

// Pattern 5: Boolean in environment variables
def debug = params.debug ?: false
def debug_val = debug ? "1" : "0"

"""
export DEBUG=${debug_val}
tool --input file.txt
"""

// Pattern 6: Boolean for conditional command execution
def skip_step = params.skip_step ?: false

"""
${skip_step ? '# Skipped' : 'tool --input file.txt'}
"""

// Pattern 7: Boolean in shell test conditions
def condition = params.enable_feature ?: false
def test_val = condition ? "true" : "false"

"""
if [ "${test_val}" = "true" ]; then
    echo "Feature enabled"
    enable_feature
else
    echo "Feature disabled"
fi
"""

// Pattern 8: Boolean to on/off
def feature = params.feature ?: false
def feature_state = feature ? "on" : "off"

"""
tool --feature ${feature_state}
"""
```

**Best Practices:**

```groovy
// ✅ Use string "true"/"false" for shell string comparisons
def bool_str = condition ? "true" : "false"
"""
if [ "${bool_str}" = "true" ]; then
    # code
fi
"""

// ✅ Use numeric 1/0 for shell numeric tests
def bool_num = condition ? 1 : 0
"""
if [ ${bool_num} -eq 1 ]; then
    # code
fi
"""

// ✅ Use conditional flag presence (most common)
def flag = condition ? "--flag" : ""
"""
tool ${flag} --input file.txt
"""

// ✅ Build flags list for multiple conditions
def flags = []
if (condition1) flags << "--flag1"
if (condition2) flags << "--flag2"
"""
tool ${flags.join(' ')} --input file.txt
"""

// ❌ Avoid direct boolean interpolation (may not work as expected)
// """
// if [ ${condition} ]; then  # May not work correctly
//     # code
// fi
// """

// ✅ Explicit conversion for clarity
def shell_condition = condition ? "true" : "false"
"""
if [ "${shell_condition}" = "true" ]; then
    # code
fi
```

### Type Casting with `as`

```groovy
// Basic type casting
def str = "42"
def num = str as Integer            // 42

def num = 3.14
def int_val = num as Integer        // 3 (truncates)

// Collection casting
def list = [1, 2, 3]
def array = list as int[]           // int array

def map = [a: 1, b: 2]
def list = map as List              // List of entries

// Safe casting (returns null if fails)
def str = "not_a_number"
def num = str as Integer            // null (if conversion fails)

// Type checking before casting
if (value instanceof String) {
    def num = value as Integer
}
```

### Implicit Conversions

```groovy
// Groovy performs some implicit conversions
def str = "42"
def sum = str + 10                  // "4210" (string concatenation)
def sum = str.toInteger() + 10      // 52 (explicit conversion needed)

// In comparisons
def str = "42"
if (str == 42) {                    // true (Groovy converts for comparison)
    // code
}

// In arithmetic (requires explicit conversion)
def str = "42"
def result = str.toInteger() * 2    // 84
```

### Common Conversion Patterns in Nextflow

```groovy
// Parameter conversion
def threads = params.threads.toString()  // Convert to string for command
def threads = params.threads ?: 1         // Default value

// File path conversion
def file = file('/path/to/file.txt')
def path_str = file.toString()            // "/path/to/file.txt"
def path_str = file.absolutePath          // Also returns string

// List to comma-separated string
def samples = ['s1', 's2', 's3']
def csv = samples.join(',')               // "s1,s2,s3"

// String to list
def csv = "s1,s2,s3"
def samples = csv.split(',')             // ['s1', 's2', 's3']
def samples = csv.split(',').toList()     // Explicit list

// Number formatting
def count = 1000000
def formatted = String.format("%,d", count)  // "1,000,000"
def formatted = count.toString()            // "1000000"

// Boolean to string for commands
def verbose = params.verbose ?: false
def flag = verbose ? "--verbose" : ""     // Conditional flag

// Map to string representation
def meta = [id: 's1', type: 'riboseq']
def meta_str = meta.toString()            // "[id:s1, type:riboseq]"

// JSON-like string to map (requires parsing)
def json_str = '{"id":"s1","type":"riboseq"}'
// Use JsonSlurper for parsing JSON strings
```

### Conversion Methods Summary

| From | To | Method |
|------|-----|--------|
| String | Integer | `as Integer`, `toInteger()`, `Integer.parseInt()` |
| String | Float/Double | `as Float`, `toFloat()`, `as Double`, `toDouble()` |
| String | Boolean | `toBoolean()`, `Boolean.parseBoolean()` |
| Number | String | `toString()`, `String.valueOf()`, interpolation |
| List | Array | `as Type[]`, `toArray()` |
| Array | List | `as List`, `toList()` |
| List | Set | `as Set`, `toSet()` |
| Set | List | `as List`, `toList()` |
| Map | List | `keySet().toList()`, `values().toList()` |
| File | String | `toString()`, `absolutePath`, automatic in triple quotes |

### Best Practices

```groovy
// ✅ Explicit conversion for clarity
def count = params.count.toString()
def threads = params.threads.toInteger()

// ✅ Use type checking before conversion
if (value instanceof String) {
    def num = value.toInteger()
}

// ✅ Handle conversion failures
def num = value?.toInteger() ?: 0  // Safe conversion with default

// ✅ Use appropriate methods
def list = csv.split(',').toList()  // Explicit list conversion
def joined = list.join(',')          // List to string

// ❌ Avoid implicit conversions in arithmetic
// def result = "42" * 2  // Won't work as expected

// ✅ Explicit conversion for arithmetic
def result = "42".toInteger() * 2    // 84
```

---

---

## Collections (Ranges, Lists and Maps)

### Ranges

Ranges represent a sequence of values from a start to an end point.

**Constructors:**

```groovy
// Integer ranges
def range1 = 1..10        // Inclusive range: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
def range2 = 1..<10      // Exclusive range: [1, 2, 3, 4, 5, 6, 7, 8, 9]
def range3 = 10..1       // Reverse range: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

// Character ranges
def charRange = 'a'..'z'  // ['a', 'b', 'c', ..., 'z']
def charRange2 = 'A'..'Z' // ['A', 'B', 'C', ..., 'Z']

// Date ranges (with Date objects)
def date1 = new Date()
def date2 = date1 + 7
def dateRange = date1..date2

// Using range constructor
def range = new IntRange(1, 10, true)  // Inclusive
def range = new IntRange(1, 10, false) // Exclusive
```

**Operators:**

```groovy
// Range operators
def range = 1..10

// Contains operator
def contains = 5 in range        // true
def contains = 15 in range       // false
def contains = range.contains(5) // true

// Subscript operator
def first = range[0]              // 1
def last = range[-1]              // 10
def slice = range[2..5]           // [3, 4, 5, 6]

// Size
def size = range.size()           // 10

// Iteration
range.each { println it }         // Iterate over each value
range.eachWithIndex { val, idx -> println "${idx}: ${val}" }

// Reverse
def reversed = range.reverse()    // [10, 9, 8, ..., 1]

// Step
def stepped = range.step(2)       // [1, 3, 5, 7, 9]
def stepped = range.step(3)       // [1, 4, 7, 10]

// Convert to list
def list = range.toList()         // [1, 2, 3, ..., 10]
```

**Common Use Cases:**

```groovy
// Iterate over range
for (i in 1..10) {
    println i
}

// Array/list indexing
def samples = ['s1', 's2', 's3', 's4', 's5']
def firstThree = samples[0..2]   // ['s1', 's2', 's3']
def lastTwo = samples[-2..-1]     // ['s4', 's5']

// String slicing
def text = "Hello World"
def substring = text[0..4]        // "Hello"
def substring = text[6..10]       // "World"

// Generate sequences
def indices = (0..samples.size()-1)
def evenNumbers = (0..100).step(2)

// Conditional checks
if (count in 1..10) {
    // count is between 1 and 10 (inclusive)
}

if (count in 1..<10) {
    // count is between 1 and 9 (exclusive of 10)
}

// In Nextflow: array indices, loop counters
def fileIndices = 0..<files.size()
fileIndices.each { idx ->
    processFile(files[idx])
}
```

**Range Properties:**

```groovy
def range = 1..10

range.from        // 1 - start value
range.to          // 10 - end value
range.inclusive   // true - whether end is included
range.exclusive   // false - whether end is excluded
range.reverse     // false - whether range is reversed
```

**Range Methods:**

```groovy
def range = 1..10

// Check bounds
range.contains(5)           // true
range.containsWithinBounds(5) // true
range.isReverse()           // false

// Transform
range.collect { it * 2 }    // [2, 4, 6, ..., 20]
range.findAll { it % 2 == 0 } // [2, 4, 6, 8, 10]

// Aggregate
range.sum()                 // 55
range.min()                 // 1
range.max()                 // 10
range.count { it > 5 }      // 5
```

### Lists

```groovy
// Create lists
def samples = ['sample1', 'sample2', 'sample3']
def numbers = [1, 2, 3, 4, 5]
def mixed = ['text', 42, true]

// Access elements
def first = samples[0]
def last = samples[-1]  // Last element
def range = samples[0..2]  // Slice

// List operations
samples.add('sample4')
samples << 'sample5'  // Append
samples.remove('sample1')
samples.size()
samples.isEmpty()
samples.contains('sample2')

// Iteration
samples.each { item -> println item }  // Iterate over each element
samples.eachWithIndex { item, index -> println "${index}: ${item}" }  // With index

// Transformation
def mapped = samples.collect { it.toUpperCase() }  // Transform each element
def collected = samples.collect { [id: it, type: 'riboseq'] }  // Create new list

// Filtering and checking
def filtered = samples.findAll { it.startsWith('sample') }  // Filter elements
def found = samples.find { it == 'sample2' }  // Find first match
def any = samples.any { it.contains('1') }  // Check if any matches
def all = samples.all { it.length() > 5 }  // Check if all match (every)

// Sorting
def sorted = samples.sort()  // Sort alphabetically
def sortedDesc = samples.sort { a, b -> b <=> a }  // Sort descending
def sortedByLength = samples.sort { it.length() }  // Sort by property

// Unique elements
def unique = samples.unique()  // Remove duplicates
def uniqueBy = samples.unique { it.substring(0, 3) }  // Unique by key

// Flattening
def nested = [[1, 2], [3, 4], [5, 6]]
def flat = nested.flatten()  // [1, 2, 3, 4, 5, 6]

// Set operations
def list1 = [1, 2, 3, 4]
def list2 = [3, 4, 5, 6]
def intersection = list1.intersect(list2)  // [3, 4] - common elements
def union = list1 + list2  // [1, 2, 3, 4, 3, 4, 5, 6] - all elements
def minus = list1 - list2  // [1, 2] - elements in list1 but not in list2
def disjoint = list1.disjoint(list2)  // false - checks if no common elements

// Reversing
def reversed = samples.reverse()  // Reverse order

// Joining
def joined = samples.join(', ')  // "sample1, sample2, sample3"
def joined = samples.join('\n')  // Join with newline

// Aggregation
def count = samples.count { it.startsWith('sample') }  // Count matching elements
def sum = [1, 2, 3, 4, 5].sum()  // 15 - sum of numbers
def max = [1, 5, 3, 9, 2].max()  // 9 - maximum value
def min = [1, 5, 3, 9, 2].min()  // 1 - minimum value
def maxBy = samples.max { it.length() }  // Maximum by property
def minBy = samples.min { it.length() }  // Minimum by property

// Enumerate (add index to elements)
def enumerated = samples.indexed()  // Creates map: [0: 'sample1', 1: 'sample2', ...]
def withIndex = samples.withIndex()  // Creates tuples: [['sample1', 0], ['sample2', 1], ...]
def enumerated = samples.collectWithIndex { item, index -> [index, item] }  // Custom enumerate

// List methods (functional)
def filtered = samples.findAll { it.startsWith('sample') }
def mapped = samples.collect { it.toUpperCase() }
def found = samples.find { it == 'sample2' }
def any = samples.any { it.contains('1') }
def all = samples.every { it.length() > 5 }

// Flatten nested lists
def nested = [[1, 2], [3, 4], [5, 6]]
def flat = nested.flatten()  // [1, 2, 3, 4, 5, 6]

// Join elements
def joined = samples.join(', ')  // "sample1, sample2, sample3"
```

### Maps

```groovy
// Create maps
def meta = [id: 'sample1', type: 'riboseq', condition: 'control']
def config = ['key1': 'value1', 'key2': 'value2']  // Alternative syntax

// Access elements
def id = meta.id
def id = meta['id']  // Alternative
def type = meta.get('type', 'default')  // With default

// Map operations
meta.put('replicate', 1)
meta['batch'] = 'batch1'
meta.remove('condition')
meta.size()
meta.isEmpty()
meta.containsKey('id')
meta.containsValue('riboseq')

// Iterate over maps
meta.each { key, value ->
    println "${key}: ${value}"
}

meta.each { entry ->
    println "${entry.key}: ${entry.value}"
}

// Map methods (functional)
def keys = meta.keySet()
def values = meta.values()
def filtered = meta.findAll { key, value -> value == 'riboseq' }
def mapped = meta.collect { key, value -> "${key}_${value}" }

// Merge maps
def meta1 = [id: 's1', type: 'riboseq']
def meta2 = [condition: 'control', replicate: 1]
def merged = meta1 + meta2  // {id: 's1', type: 'riboseq', condition: 'control', replicate: 1}
```

### Nested Collections

```groovy
// List of maps (common in Nextflow)
def samples = [
    [id: 'sample1', type: 'riboseq', file: '/path/to/file1.fq'],
    [id: 'sample2', type: 'rnaseq', file: '/path/to/file2.fq']
]

// Access nested elements
def firstSampleType = samples[0].type
def allIds = samples.collect { it.id }

// Map of lists
def config = [
    samples: ['s1', 's2', 's3'],
    files: ['f1.fq', 'f2.fq', 'f3.fq']
]
```

---

## Strings and String Interpolation

### String Interpolation

```groovy
// GString interpolation (double quotes)
def name = 'sample1'
def message = "Processing ${name}"
def path = "/data/${name}_R1.fastq.gz"
def count = 42
def info = "Found ${count} reads"

// Expression interpolation
def result = "Sum: ${a + b}"
def file = "${sample}_${replicate}_R${read}.fastq.gz"

// Method calls in interpolation
def info = "File: ${file.name}, Size: ${file.size()}"

// Triple-quoted strings (preserve formatting)
def script = """
    #!/bin/bash
    echo "Processing ${sample}"
    cat ${file}
"""

// Dollar-slashy strings (for complex interpolation)
// Syntax: $/.../$ where $/ starts and /$ ends
def pattern = $/regex with ${variable} and /$
def complex = $/path/to/${dir}/file.txt/$
def multiline = $/
    Line 1 with ${variable}
    Line 2 with /path/to/file
/$  // Note: closing delimiter is /$ (not /$/)
```

### String Methods

```groovy
// Basic operations
def text = "Hello World"
text.length()      // Returns string length (Java method)
text.size()        // Also returns string length (Groovy method) - equivalent to length()
text.toUpperCase()
text.toLowerCase()
text.trim()
text.replace('World', 'Nextflow')
text.replaceAll(/\d+/, 'NUMBER')  // Regex replacement

// Note: For strings, length() and size() are equivalent
// Both return the number of characters in the string
def len1 = text.length()  // 11
def len2 = text.size()     // 11 (same result)

// Checking
text.isEmpty()
text.contains('Hello')
text.startsWith('Hello')
text.endsWith('World')
text.matches(/\w+/)  // Regex match

// Concatenating
def str1 = "Hello"
def str2 = "World"

// Using + operator
def combined = str1 + " " + str2  // "Hello World"
def path = "/data/" + sample + "/file.fq"

// Using += operator
def result = "Start"
result += " middle"
result += " end"  // "Start middle end"

// Using String interpolation (recommended)
def combined = "${str1} ${str2}"  // "Hello World"
def path = "/data/${sample}/file.fq"
def info = "Sample: ${sample}, Count: ${count}"

// Using concat() method
def combined = str1.concat(" ").concat(str2)  // "Hello World"

// Using StringBuilder (for many concatenations)
def sb = new StringBuilder()
sb.append("Hello")
sb.append(" ")
sb.append("World")
def result = sb.toString()  // "Hello World"

// Using join() from list
def parts = ['Hello', 'World', 'Nextflow']
def joined = parts.join(' ')  // "Hello World Nextflow"
def path = ['/data', sample, 'file.fq'].join('/')  // "/data/sample1/file.fq"

// Using multiply operator for repetition
def repeated = "abc" * 3  // "abcabcabc"
def dashes = "-" * 10     // "----------"

// Splitting
def parts = "sample1,sample2,sample3".split(',')
def parts = "sample1\tsample2".split(/\t/)

// Joining (from list)
def joined = ['a', 'b', 'c'].join(', ')  // "a, b, c"

// Substring
def sub = text.substring(0, 5)  // "Hello"
def sub = text[0..4]  // "Hello" (range operator)

// Padding
def padded = "42".padLeft(5, '0')  // "00042"
def padded = "42".padRight(5, ' ')  // "42   "
```

### String Formatting

```groovy
// printf-style formatting
def formatted = String.format("Sample: %s, Count: %d", sample, count)
def formatted = sprintf("Sample: %s, Count: %d", sample, count)

// Padding with format
def padded = String.format("%05d", 42)  // "00042"
def decimal = String.format("%.2f", 3.14159)  // "3.14"
```

---

## Closures

### Basic Closures

```groovy
// Simple closure
def closure = { println "Hello" }
closure()

// Closure with parameters
def greet = { name -> println "Hello ${name}" }
greet('Nextflow')

// Closure with multiple parameters
def add = { a, b -> a + b }
def sum = add(3, 4)  // 7

// Implicit parameter (it)
def double = { it * 2 }
def result = double(5)  // 10

// Closure as variable
def process = { item ->
    // Process item
    item.toUpperCase()
}
```

### Closures with Collections

```groovy
// List methods with closures
def numbers = [1, 2, 3, 4, 5]

// each - iterate (returns original collection)
numbers.each { println it }
numbers.each { num -> println num * 2 }

// collect - transform (returns new list)
def doubled = numbers.collect { it * 2 }  // [2, 4, 6, 8, 10]

// findAll - filter (returns new list)
def evens = numbers.findAll { it % 2 == 0 }  // [2, 4]

// find - find first match (returns element)
def found = numbers.find { it > 3 }  // 4

// any - check if any matches (returns boolean)
def hasEven = numbers.any { it % 2 == 0 }  // true

// every - check if all match (returns boolean)
def allPositive = numbers.every { it > 0 }  // true

// inject - accumulate (fold/reduce)
def sum = numbers.inject(0) { acc, num -> acc + num }  // 15
def product = numbers.inject(1) { acc, num -> acc * num }  // 120

// groupBy - group by key
def grouped = numbers.groupBy { it % 2 == 0 ? 'even' : 'odd' }
// {even: [2, 4], odd: [1, 3, 5]}

// sort - sort with closure
def sorted = numbers.sort { a, b -> b <=> a }  // Descending
```

### Closure Scope

```groovy
// Closure can access variables from outer scope
def prefix = 'sample_'
def process = { id -> "${prefix}${id}" }

// Modify outer variables
def count = 0
def increment = { count++ }
increment()
increment()
// count is now 2
```

---

## Conditional Logic

### If-Else

```groovy
// Basic if
if (condition) {
    // code
}

// If-else
if (condition) {
    // code
} else {
    // code
}

// If-else if
if (condition1) {
    // code
} else if (condition2) {
    // code
} else {
    // code
}

// Ternary operator
def result = condition ? valueIfTrue : valueIfFalse
def type = params.single_end ? 'single' : 'paired'
```

### Switch Statement

```groovy
// Switch with strings
switch (params.trimmer) {
    case 'trimgalore':
        // code
        break
    case 'fastp':
        // code
        break
    default:
        // code
}

// Switch with ranges
switch (count) {
    case 0..10:
        // code
        break
    case 11..100:
        // code
        break
    default:
        // code
}

// Switch with types
switch (value) {
    case String:
        // code
        break
    case List:
        // code
        break
    default:
        // code
}
```

### Null-Safe Operations

```groovy
// Null-safe navigation
def value = object?.property?.subProperty

// Elvis operator (default value)
def name = params.name ?: 'default'
def count = params.count ?: 0

// Safe navigation with method calls
def result = object?.method()?.property

// Check for null
if (value != null) {
    // code
}

if (value) {  // Also checks for empty string, empty list, etc.
    // code
}
```

---

## Loops and Iteration

### For Loops

```groovy
// Traditional for loop
for (int i = 0; i < 10; i++) {
    println i
}

// For-in loop (most common - foreach-style)
for (item in list) {
    println item
}
```

### ForEach-Style Iteration

Groovy provides several ways to iterate over collections (foreach-style):

```groovy
// Using each() - Groovy's foreach equivalent
list.each { item ->
    println item
}

// Using each() with implicit 'it'
list.each { println it }

// Using eachWithIndex() - with index
list.eachWithIndex { item, index ->
    println "${index}: ${item}"
}

// Using for-in loop (also foreach-style)
for (item in list) {
    println item
}

// Using for-in with index
for (int i = 0; i < list.size(); i++) {
    println "${i}: ${list[i]}"
}

// Using for-in with range
for (i in 0..<list.size()) {
    println "${i}: ${list[i]}"
}
```

**Comparison:**

- **`each()`**: Functional style, returns the original collection (for chaining)
- **`for-in`**: Imperative style, more familiar to Java/C programmers
- **`eachWithIndex()`**: Functional style with index
- Both are equivalent for simple iteration

**Examples:**

```groovy
// Iterate over list
def samples = ['sample1', 'sample2', 'sample3']
samples.each { sample ->
    println "Processing ${sample}"
}

// Iterate over map
def meta = [id: 's1', type: 'riboseq', condition: 'control']
meta.each { key, value ->
    println "${key}: ${value}"
}

// Iterate with index
samples.eachWithIndex { sample, index ->
    println "${index + 1}. ${sample}"
}

// For-in equivalent
for (sample in samples) {
    println "Processing ${sample}"
}

// Iterate over range
for (i in 1..10) {
    println i
}

// Iterate over file lines
file.eachLine { line ->
    println line
}

file.eachLine { line, lineNumber ->
    println "${lineNumber}: ${line}"
}
```

```groovy
// For-in with index
for (int i = 0; i < list.size(); i++) {
    println "${i}: ${list[i]}"
}

// For-in with range
for (i in 0..9) {
    println i
}

// For-in with map
for (entry in map) {
    println "${entry.key}: ${entry.value}"
}

for (key, value in map) {
    println "${key}: ${value}"
}

```

### While Loops

```groovy
// While loop
def count = 0
while (count < 10) {
    println count
    count++
}

// Do-while loop
def count = 0
do {
    println count
    count++
} while (count < 10)
```

### Collection Iteration

```groovy
// Using each (most common in Nextflow)
list.each { item ->
    println item
}

list.eachWithIndex { item, index ->
    println "${index}: ${item}"
}

map.each { key, value ->
    println "${key}: ${value}"
}

// Using for-in (alternative)
for (item in list) {
    println item
}
```

---

## File Operations

### File Objects

```groovy
// Create file object
def file = new File('/path/to/file.txt')
def file = file('/path/to/file.txt')  // Nextflow helper

// Check file properties
file.exists()
file.isFile()
file.isDirectory()
file.canRead()
file.canWrite()
file.size()
file.name              // Full filename with extension (e.g., "sample1_R1.fastq.gz")
file.baseName          // Filename without extension (e.g., "sample1_R1")
file.nameWithoutExtension  // Same as baseName (alternative)
file.extension         // File extension (e.g., "gz")
file.path              // Relative path
file.absolutePath       // Absolute path
file.parent            // Parent directory path
file.lastModified()    // Last modification time

// File operations
file.createNewFile()
file.delete()
file.mkdirs()  // Create directories
```

### Reading Files

```groovy
// Read entire file
def content = file.text
def lines = file.readLines()

// Read line by line
file.eachLine { line ->
    println line
}

file.eachLine { line, lineNumber ->
    println "${lineNumber}: ${line}"
}

// Read with encoding
def content = file.getText('UTF-8')
```

### Writing Files

```groovy
// Write text
file.text = "Content"
file.write("Content")

// Append text
file.append("More content\n")

// Write lines
def lines = ['line1', 'line2', 'line3']
file.withWriter { writer ->
    lines.each { line ->
        writer.println(line)
    }
}
```

### File Path Manipulation

```groovy
// Get path components
def file = new File('/data/samples/sample1_R1.fastq.gz')
file.name              // "sample1_R1.fastq.gz" (full filename with extension)
file.baseName          // "sample1_R1" (filename without extension)
file.nameWithoutExtension  // "sample1_R1.fastq" (filename without last extension)
file.extension         // "gz" (last extension only)
file.parent            // "/data/samples" (parent directory)

// Note: baseName vs nameWithoutExtension
// - baseName: Removes ALL extensions (e.g., "file.tar.gz" -> "file")
// - nameWithoutExtension: Removes only the LAST extension (e.g., "file.tar.gz" -> "file.tar")

// Examples
def file1 = new File('sample1.fastq.gz')
file1.baseName          // "sample1"
file1.nameWithoutExtension  // "sample1.fastq"
file1.extension         // "gz"

def file2 = new File('sample1.tar.gz')
file2.baseName          // "sample1"
file2.nameWithoutExtension  // "sample1.tar"
file2.extension         // "gz"

// Path manipulation
def newPath = file.parent + "/processed/" + file.name
def newFile = new File(newPath)
```

### File Objects in Triple-Quoted Strings (Script Blocks)

In Nextflow `script:` blocks (triple-quoted strings), file objects are automatically converted to strings when interpolated:

```groovy
process EXAMPLE {
    input:
    path input_file
    
    script:
    // File objects are automatically converted to strings in triple-quoted strings
    """
    echo "Processing ${input_file}"
    tool --input ${input_file} --output output.txt
    """
    // input_file is automatically converted to its string path
}
```

**When `toString()` is Needed:**

```groovy
process EXAMPLE {
    input:
    path input_file
    
    script:
    // Automatic conversion works for simple interpolation
    def file_path = input_file  // File object
    
    """
    tool --input ${input_file}  # Works: automatic conversion
    """
    
    // But for string manipulation BEFORE interpolation, you need toString()
    def base_name = input_file.baseName  // String property - works
    def file_path_str = input_file.toString()  // Explicit conversion
    
    // When you need to manipulate the path as a string
    def output_name = "${input_file.toString().replace('.fastq', '_processed.fastq')}"
    
    """
    tool --input ${input_file} --output ${output_name}
    """
}
```

**Key Points:**

1. **Automatic Conversion in Triple Quotes**: File/Path objects are automatically converted to strings when used in `${}` interpolation within triple-quoted strings
2. **String Manipulation Requires toString()**: If you need to manipulate the path as a string (e.g., replace, substring, regex), use `toString()` first
3. **Property Access Returns Strings**: Properties like `.name`, `.baseName`, `.extension` already return strings, so no `toString()` needed
4. **Path Objects vs File Objects**: Both behave the same way in triple-quoted strings

**Examples:**

```groovy
process PROCESS {
    input:
    path input_file
    
    script:
    // ✅ Automatic conversion - no toString() needed
    def file = input_file
    """
    cat ${file}  # Works: automatic string conversion
    """
    
    // ✅ Property access returns strings - no toString() needed
    def base = input_file.baseName  // Already a string
    def ext = input_file.extension  // Already a string
    
    """
    echo "Base: ${base}, Ext: ${ext}"  # Works: already strings
    """
    
    // ❌ String manipulation requires toString()
    // This won't work as expected:
    // def modified = input_file.replace('.fastq', '.bam')  // ERROR
    
    // ✅ Correct: convert to string first
    def file_str = input_file.toString()
    def modified = file_str.replace('.fastq', '.bam')
    
    // Or use property access
    def base = input_file.baseName  // String
    def new_name = "${base}.bam"    // String manipulation
    
    """
    tool --input ${input_file} --output ${new_name}
    """
    
    // ✅ Complex path building
    def output_dir = input_file.parent.toString() + "/processed"
    def output_file = "${output_dir}/${input_file.baseName}_processed.${input_file.extension}"
    
    """
    mkdir -p ${output_dir}
    process_file ${input_file} > ${output_file}
    """
}
```

**Best Practices:**

- **In triple-quoted strings**: Use file objects directly in `${}` - automatic conversion
- **For string manipulation**: Use `toString()` or access string properties (`.name`, `.baseName`, etc.)
- **For path building**: Use string properties or `toString()` for concatenation
- **In Groovy code (outside triple quotes)**: File objects remain as objects until explicitly converted

---

## Regular Expressions

### Regular Expression Symbols Reference

Groovy uses Java regular expressions. Here's a comprehensive reference of regex symbols:

**Anchors:**

- `^` - Start of string/line
- `$` - End of string/line
- `\b` - Word boundary
- `\B` - Non-word boundary
- `\A` - Start of string (ignores multiline)
- `\Z` - End of string (ignores multiline)
- `\z` - Absolute end of string

**Character Classes:**

- `.` - Any character (except newline)
- `\d` - Digit [0-9]
- `\D` - Non-digit [^0-9]
- `\w` - Word character [a-zA-Z0-9_]
- `\W` - Non-word character [^a-zA-Z0-9_]
- `\s` - Whitespace [ \t\n\r\f]
- `\S` - Non-whitespace [^ \t\n\r\f]
- `[abc]` - Any of a, b, or c
- `[^abc]` - Not a, b, or c
- `[a-z]` - Character range (a to z)
- `[a-zA-Z]` - Multiple ranges
- `[0-9]` - Digit range

**Quantifiers:**

- `*` - Zero or more (greedy)
- `+` - One or more (greedy)
- `?` - Zero or one (optional)
- `{n}` - Exactly n times
- `{n,}` - n or more times
- `{n,m}` - Between n and m times
- `*?` - Zero or more (lazy/non-greedy)
- `+?` - One or more (lazy/non-greedy)
- `??` - Zero or one (lazy/non-greedy)
- `{n,m}?` - Between n and m times (lazy/non-greedy)

**Groups and Capturing:**

- `()` - Capturing group
- `(?:)` - Non-capturing group
- `(?<name>)` - Named capturing group
- `\1`, `\2`, etc. - Backreference to group 1, 2, etc.
- `|` - Alternation (OR)

**Lookahead/Lookbehind:**

- `(?=...)` - Positive lookahead
- `(?!...)` - Negative lookahead
- `(?<=...)` - Positive lookbehind
- `(?<!...)` - Negative lookbehind

**Special Characters (Escaped):**

- `\\` - Backslash
- `\.` - Literal dot
- `\+` - Literal plus
- `\*` - Literal asterisk
- `\?` - Literal question mark
- `\(` - Literal opening parenthesis
- `\)` - Literal closing parenthesis
- `\[` - Literal opening bracket
- `\]` - Literal closing bracket
- `\{` - Literal opening brace
- `\}` - Literal closing brace
- `\^` - Literal caret
- `\$` - Literal dollar
- `\|` - Literal pipe

**Flags (Pattern Modifiers):**

- `(?i)` - Case insensitive
- `(?m)` - Multiline mode (^ and $ match line boundaries)
- `(?s)` - Dotall mode (. matches newline)
- `(?x)` - Extended mode (ignore whitespace)

**Examples:**

```groovy
// Anchors
def pattern = ~/^sample/        // Starts with "sample"
def pattern = ~/\.fastq$/        // Ends with ".fastq"
def pattern = ~/^sample.*\.fastq$/  // Starts with "sample", ends with ".fastq"

// Character classes
def pattern = ~/\d+/            // One or more digits
def pattern = ~/[a-zA-Z]+/       // One or more letters
def pattern = ~/\w+/            // One or more word characters
def pattern = ~/[0-9]{4}/        // Exactly 4 digits

// Quantifiers
def pattern = ~/sample\d*/       // "sample" followed by zero or more digits
def pattern = ~/sample\d+/       // "sample" followed by one or more digits
def pattern = ~/sample\d?/       // "sample" followed by zero or one digit
def pattern = ~/sample\d{3}/     // "sample" followed by exactly 3 digits
def pattern = ~/sample\d{2,4}/   // "sample" followed by 2-4 digits

// Groups
def pattern = ~/(sample)(\d+)/  // Two groups: "sample" and digits
def pattern = ~/(?:sample)\d+/  // Non-capturing group
def pattern = ~/(?<id>sample\d+)/  // Named group "id"
def pattern = ~/sample\d+|control\d+/  // "sample" OR "control" followed by digits

// Lookahead/Lookbehind
def pattern = ~/sample(?=_R1)/   // "sample" followed by "_R1" (not captured)
def pattern = ~/sample(?!_R2)/   // "sample" NOT followed by "_R2"
def pattern = ~/(?<=sample_)\d+/  // Digits preceded by "sample_"
def pattern = ~/(?<!control_)\d+/  // Digits NOT preceded by "control_"

// Flags
def pattern = ~/(?i)sample/     // Case insensitive: matches "sample", "Sample", "SAMPLE"
def pattern = ~/(?m)^sample/     // Multiline: matches "sample" at start of any line
def pattern = ~/(?s).*/          // Dotall: . matches newline
def pattern = ~/(?x)sample \d+/  // Extended: ignores whitespace in pattern

// Escaped special characters
def pattern = ~/file\.txt/       // Literal dot (matches "file.txt")
def pattern = ~/file\+name/      // Literal plus
def pattern = ~/file\*name/       // Literal asterisk
def pattern = ~/file\?name/      // Literal question mark
def pattern = ~/file\(name\)/    // Literal parentheses
```

**Common Patterns for Nextflow:**

```groovy
// FASTQ filename patterns
def fastq_pattern = ~/^(.+?)_(R[12])\.fastq\.gz$/  // sample1_R1.fastq.gz
def fastq_pattern = ~/^(.+?)_(R\d+)_(L\d+)\.fastq\.gz$/  // With lane

// Sample ID extraction
def sample_pattern = ~/^([a-zA-Z0-9_-]+?)_R\d+/  // Extract sample ID

// File extension
def ext_pattern = ~/\.([^.]+)$/  // Last extension

// Numeric patterns
def number_pattern = ~/\d+/      // One or more digits
def float_pattern = ~/\d+\.\d+/  // Decimal number
def integer_pattern = ~/^-?\d+$/  // Optional negative integer

// Email pattern
def email_pattern = ~/^[\w.-]+@[\w.-]+\.\w+$/

// Path patterns
def path_pattern = ~/^\/.+/      // Absolute path starting with /
def relative_pattern = ~/^[^\/].+/  // Relative path (not starting with /)
```

### Pattern Matching

```groovy
// Create pattern
def pattern = ~/\d+/  // One or more digits. Notes: the space between '=' and '~'
def pattern = ~/sample_\d+/

// Match operator
def text = "sample_123"
if (text ==~ /\d+/) {  // Exact match
    // code
}

if (text =~ /\d+/) {  // Contains match. Notes: no space between '=' and '~'
    // code
}

// Find matches
def matcher = text =~ /sample_(\d+)/
if (matcher) {
    def sampleId = matcher[0][1]  // First capture group
}

// Multiple capture groups
def filename = "sample1_R1_L001.fastq.gz"
def matcher = filename =~ /^(.+?)_(R\d+)_(L\d+)\.(.+)$/
if (matcher) {
    def fullMatch = matcher[0][0]      // Full match: "sample1_R1_L001.fastq.gz"
    def sampleId = matcher[0][1]      // First group: "sample1"
    def readNum = matcher[0][2]        // Second group: "R1"
    def laneNum = matcher[0][3]        // Third group: "L001"
    def extension = matcher[0][4]      // Fourth group: "fastq.gz"
    
    // Access all groups at once
    def allGroups = matcher[0]         // [fullMatch, group1, group2, group3, group4]
}

// Named capture groups (Groovy 2.5+)
def filename = "sample1_R1.fastq.gz"
def matcher = filename =~ /^(?<sample>.+?)_(?<read>R\d+)\.(?<ext>.+)$/
if (matcher) {
    def sample = matcher.group('sample')  // "sample1"
    def read = matcher.group('read')      // "R1"
    def ext = matcher.group('ext')        // "fastq.gz"
}

// Multiple matches with capture groups
def text = "sample1_R1.fq sample2_R2.fq sample3_R1.fq"
def pattern = /(\w+)_(R\d+)\.fq/
def matcher = text =~ pattern

matcher.each { match ->
    def sample = match[1]  // First capture group
    def read = match[2]    // Second capture group
    println "Sample: ${sample}, Read: ${read}"
}
// Output:
// Sample: sample1, Read: R1
// Sample: sample2, Read: R2
// Sample: sample3, Read: R1
```

**Capture Group Indexing:**

- `matcher[0]` - Array containing full match and all capture groups
- `matcher[0][0]` - Full match (entire matched string)
- `matcher[0][1]` - First capture group `()`
- `matcher[0][2]` - Second capture group `()`
- `matcher[0][n]` - Nth capture group

#### Common Pattern: Extracting Components from Filenames

```groovy
// Extract sample ID and read number from FASTQ filename
def filename = "sample1_R1.fastq.gz"
def matcher = filename =~ /^(.+?)_(R[12])\.fastq\.gz$/
if (matcher) {
    def sample_id = matcher[0][1]  // "sample1"
    def read_num = matcher[0][2]   // "R1"
}

// Extract multiple components
def filename = "experiment_sample1_rep1_R1_L001.fastq.gz"
def matcher = filename =~ /^(.+?)_(.+?)_(.+?)_(R\d+)_(L\d+)\.fastq\.gz$/
if (matcher) {
    def experiment = matcher[0][1]  // "experiment"
    def sample = matcher[0][2]      // "sample1"
    def replicate = matcher[0][3]    // "rep1"
    def read = matcher[0][4]         // "R1"
    def lane = matcher[0][5]         // "L001"
}

// Extract with optional groups
def filename = "sample1_R1.fastq.gz"  // No lane number
def matcher = filename =~ /^(.+?)_(R\d+)(?:_(L\d+))?\.fastq\.gz$/
if (matcher) {
    def sample = matcher[0][1]  // "sample1"
    def read = matcher[0][2]     // "R1"
    def lane = matcher[0][3]     // null (optional group not matched)
}
```

### String Replacement

```groovy
// Replace all
def text = "sample1 sample2 sample3"
def replaced = text.replaceAll(/\d+/, 'X')  // "sampleX sampleX sampleX"

// Replace with closure
def replaced = text.replaceAll(/\d+/) { match ->
    match.toInteger() * 2
}

// Replace first
def replaced = text.replaceFirst(/\d+/, 'X')
```

### Common Patterns

```groovy
// Extract sample ID from filename
def filename = "sample1_R1.fastq.gz"
def matcher = filename =~ /^(.+?)_R\d+\./
if (matcher) {
    def sampleId = matcher[0][1]  // "sample1"
}

// Extract extension
def extension = filename =~ /\.([^.]+)$/
if (extension) {
    def ext = extension[0][1]  // "gz"
}

// Validate format
def isValid = filename ==~ /^sample_\d+_R[12]\.fastq\.gz$/
```

---

## Error Handling

### Try-Catch

```groovy
// Basic try-catch
try {
    // code that might throw exception
    def result = riskyOperation()
} catch (Exception e) {
    // handle error
    log.error("Error: ${e.message}")
}

// Multiple catch blocks
try {
    // code
} catch (FileNotFoundException e) {
    // handle file not found
} catch (IOException e) {
    // handle IO error
} catch (Exception e) {
    // handle other errors
}

// Finally block
try {
    // code
} catch (Exception e) {
    // handle error
} finally {
    // cleanup code (always executes)
}
```

### Assertions

```groovy
// Assert with message
assert condition : "Error message"
assert file.exists() : "File not found: ${file.path}"

// Assert with closure
assert { file.exists() && file.size() > 0 } : "File is empty or missing"
```

## Groovy Classes and Methods

### Class Definition

Groovy classes can be defined with properties, methods, and constructors.

**Basic Class:**

```groovy
// Simple class
class Sample {
    String id
    String type
    String condition
}

// Create instance
def sample = new Sample()
sample.id = 'sample1'
sample.type = 'riboseq'
sample.condition = 'control'

// Or with constructor
def sample = new Sample(id: 'sample1', type: 'riboseq', condition: 'control')
```

**Class with Methods:**

```groovy
class Sample {
    String id
    String type
    String condition
    
    // Method
    String getInfo() {
        return "${id} (${type}, ${condition})"
    }
    
    // Method with parameters
    boolean isType(String checkType) {
        return type == checkType
    }
    
    // Static method
    static Sample create(String id, String type) {
        return new Sample(id: id, type: type)
    }
}

// Usage
def sample = new Sample(id: 's1', type: 'riboseq', condition: 'control')
def info = sample.getInfo()           // "s1 (riboseq, control)"
def isRiboseq = sample.isType('riboseq')  // true
def newSample = Sample.create('s2', 'rnaseq')  // Static method
```

**Class with Constructor:**

```groovy
class Sample {
    String id
    String type
    String condition
    
    // Default constructor (automatic)
    Sample() {}
    
    // Custom constructor
    Sample(String id, String type) {
        this.id = id
        this.type = type
        this.condition = 'unknown'
    }
    
    // Named parameter constructor (map-based)
    Sample(Map params) {
        this.id = params.id
        this.type = params.type ?: 'unknown'
        this.condition = params.condition ?: 'unknown'
    }
}

// Usage
def sample1 = new Sample('s1', 'riboseq')
def sample2 = new Sample(id: 's2', type: 'rnaseq', condition: 'control')
```

**Class with Properties and Getters/Setters:**

```groovy
class Sample {
    // Public property (automatic getter/setter)
    String id
    
    // Private property with explicit getter/setter
    private String _type
    
    String getType() {
        return _type
    }
    
    void setType(String type) {
        this._type = type?.toLowerCase()
    }
    
    // Read-only property
    private final String _created
    
    String getCreated() {
        return _created
    }
    
    Sample(String id) {
        this.id = id
        this._created = new Date().toString()
    }
}

// Usage
def sample = new Sample('s1')
sample.type = 'RIBOSEQ'  // Automatically converted to lowercase
def created = sample.created  // Read-only
```

### Class Methods

**Instance Methods:**

```groovy
class FileProcessor {
    String inputPath
    
    // Instance method
    String getOutputPath() {
        return inputPath.replace('.fastq', '_processed.fastq')
    }
    
    // Method with parameters
    boolean isValid() {
        return inputPath != null && inputPath.endsWith('.fastq.gz')
    }
    
    // Method with multiple parameters
    String process(String outputDir, boolean verbose) {
        def output = "${outputDir}/${getOutputPath()}"
        if (verbose) {
            println "Processing ${inputPath} -> ${output}"
        }
        return output
    }
}

// Usage
def processor = new FileProcessor(inputPath: '/data/sample1.fastq.gz')
def output = processor.getOutputPath()
def valid = processor.isValid()
def result = processor.process('/output', true)
```

**Static Methods:**

```groovy
class SampleUtils {
    // Static method (class-level, no instance needed)
    static String generateId(String prefix, int number) {
        return "${prefix}_${number}"
    }
    
    static boolean isValidType(String type) {
        return ['riboseq', 'rnaseq', 'tiseq'].contains(type)
    }
    
    static List<String> extractIds(List<Map> samples) {
        return samples.collect { it.id }
    }
}

// Usage (no instance needed)
def id = SampleUtils.generateId('sample', 1)  // "sample_1"
def valid = SampleUtils.isValidType('riboseq')  // true
def ids = SampleUtils.extractIds(samples)
```

**Method Overloading:**

```groovy
class Processor {
    // Method with different parameter lists
    String process(String input) {
        return process(input, '/output')
    }
    
    String process(String input, String outputDir) {
        return process(input, outputDir, false)
    }
    
    String process(String input, String outputDir, boolean verbose) {
        if (verbose) {
            println "Processing ${input} to ${outputDir}"
        }
        return "${outputDir}/${new File(input).name}"
    }
}

// Usage
def processor = new Processor()
def result1 = processor.process('input.txt')  // Uses default outputDir
def result2 = processor.process('input.txt', '/custom')  // Uses default verbose
def result3 = processor.process('input.txt', '/custom', true)  // All parameters
```

### Common Patterns in Nextflow

**Utility Class for Pipeline Functions:**

```groovy
class PipelineUtils {
    // Static utility methods
    static Map createMeta(String id, String type, String condition) {
        return [
            id: id,
            type: type,
            condition: condition,
            single_end: false
        ]
    }
    
    static String buildPath(String dir, String sample, String suffix) {
        return "${dir}/${sample}${suffix}"
    }
    
    static boolean validateSample(Map sample) {
        return sample.id && sample.type && 
               ['riboseq', 'rnaseq', 'tiseq'].contains(sample.type)
    }
    
    static List<String> filterByType(List<Map> samples, String type) {
        return samples.findAll { it.type == type }.collect { it.id }
    }
}

// Usage in workflow
def meta = PipelineUtils.createMeta('s1', 'riboseq', 'control')
def path = PipelineUtils.buildPath('/data', 'sample1', '_R1.fastq.gz')
def valid = PipelineUtils.validateSample(meta)
def riboseqIds = PipelineUtils.filterByType(samples, 'riboseq')
```

**Data Class for Metadata:**

```groovy
class SampleMetadata {
    String id
    String type
    String condition
    Integer replicate
    List<String> files
    
    // Constructor
    SampleMetadata(String id, String type) {
        this.id = id
        this.type = type
        this.files = []
    }
    
    // Method to add file
    void addFile(String file) {
        files << file
    }
    
    // Method to check if complete
    boolean isComplete() {
        return id && type && files.size() > 0
    }
    
    // Method to get summary
    String getSummary() {
        return "${id} (${type}, ${condition ?: 'unknown'}, ${files.size()} files)"
    }
    
    // Override toString
    String toString() {
        return "SampleMetadata(id: ${id}, type: ${type}, files: ${files.size()})"
    }
}

// Usage
def meta = new SampleMetadata('s1', 'riboseq')
meta.condition = 'control'
meta.addFile('/path/to/file1.fq')
meta.addFile('/path/to/file2.fq')
def complete = meta.isComplete()  // true
def summary = meta.getSummary()   // "s1 (riboseq, control, 2 files)"
```

**Class with Inheritance:**

```groovy
// Base class
class BaseSample {
    String id
    String type
    
    String getInfo() {
        return "${id} (${type})"
    }
}

// Derived class
class RiboseqSample extends BaseSample {
    Integer offset
    String condition
    
    RiboseqSample(String id) {
        this.id = id
        this.type = 'riboseq'
    }
    
    @Override
    String getInfo() {
        return "${super.getInfo()}, offset: ${offset ?: 'unknown'}"
    }
}

// Usage
def sample = new RiboseqSample('s1')
sample.offset = 12
sample.condition = 'control'
def info = sample.getInfo()  // "s1 (riboseq), offset: 12"
```

### Best Practices for Classes

```groovy
// ✅ Use classes for complex data structures
class SampleConfig {
    String id
    Map<String, Object> metadata
    List<String> files
}

// ✅ Use static methods for utility functions
class FileUtils {
    static String getBaseName(String path) {
        return new File(path).baseName
    }
}

// ✅ Use instance methods for object-specific operations
class Sample {
    String id
    List<String> files
    
    void addFile(String file) {
        files << file
    }
}

// ✅ Override toString() for debugging
class Sample {
    String id
    String type
    
    String toString() {
        return "Sample(id: ${id}, type: ${type})"
    }
}

// ✅ Use final for immutable properties
class Config {
    final String id
    final String type
    
    Config(String id, String type) {
        this.id = id
        this.type = type
    }
}
```

---

## Common Patterns in Nextflow Workflows

### Processing Channel Elements

```groovy
// Transform channel elements
channel
    .fromPath('/data/*.fastq.gz')
    .map { file ->
        def meta = [
            id: file.baseName,
            file: file,
            size: file.size()
        ]
        [meta, file]
    }

// Filter channel elements
channel
    .fromPath('/data/*.fastq.gz')
    .filter { file ->
        file.size() > 0 && file.name.contains('_R1')
    }

// Group by key
channel
    .of(['sample1', 'file1'], ['sample1', 'file2'], ['sample2', 'file3'])
    .groupTuple()
    .map { sample, files ->
        [id: sample, files: files]
    }
```

### Building Command Strings

```groovy
// Build command with conditional arguments
def cmd = ['tool', '--input', inputFile]

if (params.option1) {
    cmd += '--option1'
}

if (params.option2) {
    cmd += '--option2', params.option2
}

def command = cmd.join(' ')

// Using list for cleaner command building
def args = []
args << '--input' << inputFile
if (params.verbose) args << '--verbose'
if (params.threads) args << '--threads' << params.threads

def command = "tool ${args.join(' ')}"
```

### Metadata Manipulation

```groovy
// Create metadata map
def meta = [
    id: sampleId,
    type: 'riboseq',
    condition: 'control',
    replicate: 1
]

// Add to metadata
meta.single_end = false
meta['batch'] = 'batch1'

// Merge metadata
def newMeta = meta + [additional: 'info']

// Clone metadata (avoid mutation)
def clonedMeta = meta.clone()
clonedMeta.id = 'new_id'

// Transform metadata
def transformed = meta.collectEntries { key, value ->
    [key.toUpperCase(), value]
}
```

### Conditional Channel Creation

```groovy
// Conditional channel
def ch_data = params.use_option ?
    channel.fromPath('/data/optional.txt') :
    channel.empty()

// Multiple conditions
def ch_input = params.input_type == 'file' ?
    channel.fromPath(params.input) :
    params.input_type == 'list' ?
    channel.fromList(params.input.split(',')) :
    channel.empty()
```

### String Building for Scripts

```groovy
// Build shell script
def script = """
    #!/bin/bash
    set -e
    
    echo "Processing ${sample}"
    
    tool \\
        --input ${inputFile} \\
        --output ${outputFile} \\
        ${params.extra_args ?: ''}
"""

// Build with conditional parts
def script = """
    tool --input ${inputFile}
"""

if (params.option1) {
    script += " --option1"
}

if (params.option2) {
    script += " --option2 ${params.option2}"
}
```

### File Path Construction

```groovy
// Build file paths
def outputDir = "${params.outdir}/results"
def outputFile = "${outputDir}/${sample}_processed.bam"

// Using file operations
def outputFile = new File(params.outdir, "results/${sample}_processed.bam")
def outputPath = outputFile.absolutePath

// Path manipulation
def baseName = file.nameWithoutExtension
def newName = "${baseName}_processed.${file.extension}"
def newPath = "${file.parent}/${newName}"
```

### Collection Operations

```groovy
// Process list of samples
def samples = ['sample1', 'sample2', 'sample3']
def processed = samples.collect { sample ->
    "${sample}_processed"
}

// Filter and transform
def validSamples = samples
    .findAll { it.startsWith('sample') }
    .collect { it.toUpperCase() }

// Group by property
def samples = [
    [id: 's1', type: 'riboseq'],
    [id: 's2', type: 'rnaseq'],
    [id: 's3', type: 'riboseq']
]
def grouped = samples.groupBy { it.type }
// {riboseq: [[id: 's1', ...], [id: 's3', ...]], rnaseq: [[id: 's2', ...]]}
```

### Validation and Error Checking

```groovy
// Validate parameters
if (!params.input) {
    error "Input parameter is required"
}

if (!file(params.input).exists()) {
    error "Input file not found: ${params.input}"
}

// Validate with assertions
assert params.threads > 0 : "Threads must be positive"
assert file.exists() : "File not found: ${file.path}"

// Check collections
if (samples.isEmpty()) {
    log.warn("No samples found")
    return
}

if (!samples.any { it.type == 'riboseq' }) {
    log.warn("No riboseq samples found")
}
```

### Complex Data Structures

```groovy
// Nested maps and lists (common in Nextflow)
def sampleData = [
    id: 'sample1',
    files: [
        fastq_1: '/path/to/R1.fq',
        fastq_2: '/path/to/R2.fq'
    ],
    metadata: [
        type: 'riboseq',
        condition: 'control',
        replicate: 1
    ]
]

// Access nested data
def fastq1 = sampleData.files.fastq_1
def type = sampleData.metadata.type

// Transform nested structures
def allTypes = samples.collect { it.metadata.type }.unique()
```

---

## Quick Reference

### Most Common Operations

```groovy
// String interpolation
"Value: ${variable}"

// Null-safe
value?.property
value ?: 'default'

// List operations
list.collect { transform }
list.findAll { filter }
list.find { condition }
list.any { condition }
list.every { condition }
list.join(', ')

// Map operations
map.each { key, value -> ... }
map.collect { key, value -> ... }
map.findAll { key, value -> ... }
map.keySet()
map.values()

// File operations
file.exists()
file.text
file.readLines()
file.name
file.baseName
file.extension

// Regular expressions
text =~ /pattern/
text.replaceAll(/pattern/, 'replacement')

// Conditionals
condition ? valueIfTrue : valueIfFalse
value ?: defaultValue
```

---

## References

- [Groovy Documentation](https://groovy-lang.org/documentation.html)
- [Groovy Style Guide](https://groovy-lang.org/style-guide.html)
- [Nextflow Documentation](https://www.nextflow.io/docs/latest/)
- Current pipeline examples: `workflows/riboseq/main.nf`, `subworkflows/**/main.nf`
