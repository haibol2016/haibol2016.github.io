---
layout: post
title: "Pandas Learning Guide for Users from the R Side"
date: 2026-01-17
categories: [data-science, python, pandas, data-analysis, r]
tags: [pandas, python, data-analysis, data-science, r, r-to-python, series, dataframe, plotting, matplotlib, seaborn, tutorial, practice, comparison]
author: Haibo Liu, PhD
toc: true
excerpt: "A comprehensive Pandas guide designed for R users, with side-by-side comparisons of data structures and operations between R and Pandas to facilitate smooth transition from R to Python."
---

## Introduction

**Welcome, R users!** This guide is specifically designed to help you transition from R to Pandas (Python's data manipulation library). If you're familiar with R's data structures like vectors, data.frames, and the tidyverse ecosystem, this guide will show you the Pandas equivalents with side-by-side comparisons.

Pandas is Python's equivalent to R's data manipulation capabilities, providing similar functionality for working with structured data. Whether you're working with genomics data, analyzing experimental results, or processing any structured data, Pandas offers tools that will feel familiar if you know R.

**This guide will help you understand**:
- How Pandas Series relate to R vectors and named vectors
- How Pandas DataFrames compare to R data.frames
- How Pandas operations map to R's dplyr, tidyr, and base R functions
- Key conceptual differences between R and Pandas (especially indexing)
- Side-by-side code comparisons throughout

**This guide covers**:
- **Pandas Series**: One-dimensional labeled arrays (vs R vectors/named vectors)
- **Pandas DataFrame**: Two-dimensional labeled data structures (vs R data.frames)
- **Data Manipulation**: Operations similar to dplyr, tidyr, and base R
- **Plotting**: Visualization with Pandas built-in plotting, Matplotlib/Seaborn, and Lets-Plot (ggplot2-like)
- **Practice Questions**: Hands-on exercises to reinforce your learning

**Key Philosophy**: This guide assumes you know R and want to learn Pandas. We'll constantly reference R equivalents to help you understand Pandas concepts.

## Prerequisites

Before starting, ensure you have Pandas installed:

```bash
pip install pandas matplotlib seaborn
```

Or with conda:

```bash
conda install pandas matplotlib seaborn
```

**Optional**: For ggplot2-style plotting (useful for R users), install Lets-Plot:

```bash
pip install lets-plot
```

## Part 1: Pandas Series

### What is a Series?

A Series is a one-dimensional labeled array that is **best kept homogeneous** (all elements of the same data type) for optimal performance. While a Series can technically hold mixed data types (integers, strings, floats, Python objects, etc.), mixed-type Series are stored as `object` dtype, which is less memory-efficient and slower for operations. It's similar to a column in a spreadsheet or a dictionary with ordered keys.

**For R users**: A Pandas Series is conceptually similar to an **R named vector**, but with enhanced functionality:
- **Similarities**: Both are one-dimensional, both have names/labels for elements, both can be accessed by name
- **Differences**: Pandas Series have more features like index alignment, vectorized operations, and integration with DataFrames. R named vectors are simpler structures.

**R named vector example**:
```r
# R
vec <- c(a=10, b=20, c=30)
vec["a"]  # Access by name
```

**Pandas Series equivalent**:
```python
# Python/Pandas
s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
s['a']  # Access by index label
```

**Best Practice**: Keep Series homogeneous (e.g., all integers, all floats, all strings) to leverage Pandas' optimized operations and reduce memory usage.

### Understanding Series Index

**Important**: Series do **not** have columns - only DataFrames have columns. A Series has:
- **Index**: The labels that identify each element (like row names)
- **Values**: The actual data stored in the Series

The index provides a way to label and access data elements. By default, if you don't specify an index, Pandas creates a RangeIndex (0, 1, 2, 3, ...), similar to array indices in NumPy or list indices in Python.

**Important for R users: Pandas index is conceptually different from R's indexing**:

In **R**, indexing typically refers to:
- **Position-based access**: `vec[1]` accesses the first element (1-indexed)
- **Row names**: Optional labels stored separately from data (`rownames()`)
- **No built-in alignment**: Operations align by position, not by names

In **Pandas**, index is:
- **A first-class object**: Index is an integral part of the data structure, not just metadata
- **Label-based by default**: Operations align by index labels, not positions
- **Always present**: Every Series/DataFrame has an index (even if it's just 0, 1, 2, ...)
- **Used for alignment**: When performing operations, Pandas aligns by index labels automatically

**Key conceptual differences**:

```r
# R - Position-based indexing (1-indexed)
vec <- c(10, 20, 30)
vec[1]  # Returns 10 (first element)
names(vec) <- c("a", "b", "c")
vec["a"]  # Access by name, but names are separate from indexing

# R - Row names are separate
df <- data.frame(x=1:3, y=4:6, row.names=c("a", "b", "c"))
df["a", ]  # Access by row name
df[1, ]    # Access by position (1-indexed)
```

```python
# Pandas - Index is integral to the structure
s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
s['a']     # Access by index label
s.iloc[0]  # Access by position (0-indexed, must use .iloc)

# Pandas - Index alignment in operations
s1 = pd.Series([10, 20], index=['a', 'b'])
s2 = pd.Series([30, 40], index=['b', 'a'])  # Different order
s1 + s2  # Aligns by index: a=10+40=50, b=20+30=50 (not position-based!)

# In R, this would be position-based:
# s1 + s2 would give: 10+30=40, 20+40=60 (position-based, not name-based)
```

**Summary of differences**:

| Feature | R named vector | Pandas Series |
|---------|----------------|---------------|
| **Indexing system** | Position-based (1-indexed) | Label-based (index labels) |
| **Names/Labels** | Optional names (`names(vec)`) | Always present index (integral part) |
| **Alignment** | By position | By index labels |
| **Access by name** | `vec["name"]` | `s["name"]` or `s.loc["name"]` |
| **Access by position** | `vec[1]` (1-indexed, first element) | `s.iloc[0]` (0-indexed, first element) |
| **Operations** | Position-aligned | Index-aligned (automatic) |
| **Default index** | No default (just positions 1,2,3...) | Default RangeIndex (0,1,2...) if not specified |

**Key points about Series index**:
- **Default index**: If not specified, uses integer positions (0, 1, 2, ...) - you **cannot** create a Series without an index, but you can create one without explicitly specifying it (it will use default RangeIndex)
- **Custom index**: Can use strings, integers, dates, or any hashable type
- **Index uniqueness**: Series index does **not** have to be unique - duplicate index labels are allowed, but can cause issues with certain operations (see examples below)
- **Index is immutable**: Once created, you cannot modify individual index labels (but you can reassign the entire index)
- **Index alignment**: When performing operations between Series, Pandas aligns data by index labels, not positions
- **No columns**: Series are one-dimensional - they only have an index and values, not columns

**Creating Series without explicit index**:
```python
# Series always has an index - if not specified, uses default RangeIndex
s1 = pd.Series([10, 20, 30])  # Index: 0, 1, 2 (default)
s2 = pd.Series([10, 20, 30], index=None)  # Same as above - still creates default index
# Note: You cannot create a Series truly without an index
```

**Resetting index**:
```python
# Create Series with custom index
s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])

# Method 1: reset_index() - converts index to a column (returns DataFrame!)
s_reset = s.reset_index()
print(s_reset)
# Output:
#    index    0
# 0      a   10
# 1      b   20
# 2      c   30
# Note: reset_index() on Series returns a **DataFrame**, not a Series!

# Method 2: Using reset_index(drop=True) - returns Series with default integer index
# (drop=True drops the old index instead of making it a column)
s_reset = s.reset_index(drop=True)  # Returns Series with default RangeIndex (0, 1, 2, ...)

# Method 3: Reset index while keeping as Series - reassign index directly
s.index = range(len(s))  # Reset to 0, 1, 2, ...
# Or create new Series with default index
s_new = pd.Series(s.values)  # Uses default RangeIndex (0, 1, 2, ...)
# Or explicitly
s_new = pd.Series(s.values, index=pd.RangeIndex(len(s)))

```

**Index uniqueness**:
```python
# Series index does NOT have to be unique - duplicates are allowed
s_dup = pd.Series([10, 20, 30, 40], index=['a', 'b', 'a', 'c'])
print(s_dup)
# Output:
# a    10
# b    20
# a    30
# c    40
# dtype: int64

# Accessing with duplicate index returns multiple values
print(s_dup['a'])  # Returns Series with both 'a' values: a=10 and a=30

# Check if index is unique
s_dup.index.is_unique  # Returns: False

# Make index unique (keeps first occurrence by default)
s_unique = s_dup[~s_dup.index.duplicated(keep='first')]
# Or
s_unique = s_dup.groupby(s_dup.index).first()  # Keep first value for each index

# Warning: Some operations may fail or behave unexpectedly with duplicate indices
# For example, reindexing or certain alignment operations
```

**Example**:
```python
s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
# Index: ['a', 'b', 'c']
# Values: [10, 20, 30]
# No columns - Series are 1D structures
```

### Creating a Series

```python
import pandas as pd
import numpy as np

# From a list, using default index
s1 = pd.Series([1, 3, 5, 7, 9])
print(s1)
# Output:
# 0    1
# 1    3
# 2    5
# 3    7
# 4    9
# dtype: int64

# With custom index
s2 = pd.Series([10, 20, 30, 40], index=['a', 'b', 'c', 'd'])
print(s2)
# Output:
# a    10
# b    20
# c    30
# d    40
# dtype: int64

# From a dictionary
data = {'apple': 3, 'banana': 2, 'orange': 5}
s3 = pd.Series(data)
print(s3)
# Output:
# apple     3
# banana    2
# orange    5
# dtype: int64

# From NumPy array
arr = np.array([1.5, 2.5, 3.5, 4.5])
s4 = pd.Series(arr, index=['x', 'y', 'z', 'w'])
print(s4)

# Mixed types (not recommended - stored as object dtype)
s5 = pd.Series([1, 'two', 3.0, True])
print(s5)
print(s5.dtype)  # Output: object
# Note: Mixed-type Series are less efficient. Keep Series homogeneous when possible.
```

### Key Series Operations

#### Accessing Data

```python
# By index label
s2['b']  # Returns: 20

# By position (iloc)
s2.iloc[1]  # Returns: 20

# By position (integer index)
s1[1]  # Returns: 3

# Slicing with index labels or integer indices
s2['b':'d']  # Returns Series with b, c, d
s2.iloc[1:3]  # Returns Series with positions 1, 2
```

#### Basic Operations

```python
# Arithmetic operations
s1 * 2  # Multiply all values by 2
s1 + s1  # Element-wise addition (if same index)

# Statistical operations
s1.mean()  # Mean value
s1.std()   # Standard deviation
s1.sum()   # Sum of values
s1.min()   # Minimum value
s1.max()   # Maximum value
s1.median()  # Median value

# Boolean indexing
s1[s1 > 5]  # Returns Series with values > 5

# Check for null values
s1.isna()   # Returns boolean Series
s1.notna()  # Returns boolean Series
s1.dropna() # Remove null values
```

#### Series Methods

```python
# Value counts
s = pd.Series(['a', 'b', 'a', 'c', 'b', 'a'])
s.value_counts()
# Output:
# a    3
# b    2
# c    1
# dtype: int64

# Sort
s2.sort_values()  # Sort by values
s2.sort_index()  # Sort by index

# Reset index
s_custom = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
# Reset to default integer index (returns DataFrame - index becomes a column)
s_custom.reset_index()  # Returns DataFrame with 'index' column
# To reset index and keep as Series, reassign index directly:
s_custom.index = range(len(s_custom))  # Now has index 0, 1, 2

# Apply function
s1.apply(lambda x: x**2)  # Square each value

# String operations (for string Series)
s_str = pd.Series(['apple', 'banana', 'cherry'])
s_str.str.upper()  # Convert to uppercase
s_str.str.len()    # Get length of each string

# Convert Series to NumPy array
arr = s1.to_numpy()  # Returns NumPy array (recommended)
arr = s1.values      # Alternative (legacy, still works)
# Note: Index is lost when converting to NumPy array

# Check and handle duplicate indices
s_dup = pd.Series([10, 20, 30], index=['a', 'b', 'a'])
s_dup.index.is_unique  # Check if index is unique (returns False if duplicates exist)
s_dup.index.duplicated()  # Returns boolean array indicating duplicate indices
# Remove duplicates (keep first occurrence)
s_unique = s_dup[~s_dup.index.duplicated(keep='first')]
# Or group by index and aggregate
s_unique = s_dup.groupby(s_dup.index).first()  # Keep first value for each index
```

## Part 2: Pandas DataFrame

### What is a DataFrame?

A DataFrame is a two-dimensional labeled data structure with columns of potentially different types. It's similar to a spreadsheet or SQL table, and is the most commonly used Pandas object.

**R Equivalent**: Pandas DataFrame is very similar to R's **data.frame**, but with important structural differences:

| Feature | R data.frame | Pandas DataFrame |
|---------|--------------|------------------|
| **Row identification** | Optional row names (`rownames()`) | Always has row index (integral part) |
| **Column access** | `df$col` or `df[["col"]]` | `df['col']` or `df.col` |
| **Row access** | `df[1, ]` (1-indexed) or `df["rowname", ]` | `df.iloc[0]` (0-indexed) or `df.loc["rowname"]` |
| **Index/Row names** | Separate metadata (`rownames()`) | Integral part of structure (`.index`) |
| **Operations alignment** | Position-based by default | Index-label-based (automatic alignment) |
| **Column types** | Can mix types (list columns possible) | Each column is homogeneous (like R) |
| **Subsetting** | `df[rows, cols]` (1-indexed) | `df.loc[rows, cols]` (label-based) or `df.iloc[rows, cols]` (position-based, 0-indexed) |

**Key Similarities**:
- Both are two-dimensional structures
- Both have named columns
- Both can have different column types
- Both support similar operations (filtering, grouping, merging)

**Key Differences**:
- **Index is always present** in Pandas (even if just 0,1,2,...)
- **Index is integral** to operations (alignment happens by index, not position)
- **0-indexed** in Pandas vs **1-indexed** in R
- Pandas uses `.loc` and `.iloc` to distinguish label vs position access

**DataFrame Structure: Row Index and Column Labels**

Yes! A DataFrame has **both**:
- **Row index** (`.index`): Labels for rows - similar to row names in R or Excel
- **Column labels** (`.columns`): Names for columns - similar to column headers

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['NYC', 'LA', 'NYC']
}, index=['a', 'b', 'c'])

print(df.index)    # Index(['a', 'b', 'c'], dtype='object') - Row index
print(df.columns)  # Index(['name', 'age', 'city'], dtype='object') - Column labels
```

**Visual representation of DataFrame structure**:

```
                    Column Labels (df.columns)
                    ┌─────────┬──────┬─────────┐
                    │  name   │ age  │  city   │
                    ├─────────┼──────┼─────────┤
Row Index (df.index)│         │      │         │
         ┌──────────┤         │      │         │
         │    a     │ Alice   │  25  │   NYC   │  ← Row 'a' (df.loc['a'], or df.iloc[0])
         ├──────────┤         │      │         │
         │    b     │  Bob    │  30  │   LA    │  ← Row 'b' (df.loc['b'], or df.iloc[1])
         ├──────────┤         │      │         │
         │    c     │ Charlie │  35  │   NYC   │  ← Row 'c' (df.loc['c'], or df.iloc[2])
         └──────────┴─────────┴──────┴─────────┘
                    │         │      │
                    │         │      │
                    ▼         ▼      ▼
              df['name']   df['age']  df['city']
        df.loc[:, 'name']  df.loc[:, 'age'] df.loc[:, 'city']
            df.iloc[:, 0]  df.iloc[:, 1] df.iloc[:, 2]
               (Column)    (Column)  (Column)
```

**Simpler table view**:

| Row Index → | Column: `name` | Column: `age` | Column: `city` |
|-------------|----------------|---------------|----------------|
| **`'a'`**    | Alice          | 25            | NYC            |
| **`'b'`**    | Bob            | 30            | LA             |
| **`'c'`**    | Charlie        | 35            | NYC            |

- **Row Index** (left column): Labels each row → `df.index` = `['a', 'b', 'c']`
- **Column Labels** (top row): Labels each column → `df.columns` = `['name', 'age', 'city']`
- **Data cells**: Intersection of row index and column label

**Accessing data**:
- **By row index**: `df.loc['a']` → Returns row 'a' (Alice, 25, NYC)
- **By column label**: `df['name']` → Returns column 'name' (Alice, Bob, Charlie)
- **By both**: `df.loc['a', 'name']` → Returns 'Alice' (row 'a', column 'name')

**Key points**:
- **Row index**: Identifies each row (can be strings, integers, dates, etc.)
- **Column labels**: Identifies each column (typically strings, but can be other types)
- **Both are Index objects**: Both `.index` and `.columns` are Pandas Index objects
- **Both can be used for label-based access**: 
  - Row index: `df.loc['a']` (access row by index label)
  - Column labels: `df['name']` or `df.loc[:, 'name']` (access column by label)
- **Default row index**: If not specified, uses RangeIndex (0, 1, 2, ...)
- **Column labels**: Must be specified (either explicitly or inferred from data)

**Important distinction**:
- **Row index** is what we typically call "the index" in Pandas
- **Column labels** are called "columns" - they're not usually called "column index" in Pandas terminology, though they serve a similar indexing purpose

**For R users: DataFrame index vs R data.frame row names**:

In **R**, data frames have:
- **Row names**: Optional, set with `rownames()` or `row.names` parameter
- **Position-based access**: `df[1, ]` accesses first row (1-indexed)
- **row names based access** `df['a', ]` (R data.frame's rownames must be unique)
- **Row names are separate**: Not integral to operations, mainly for display

In **Pandas**, DataFrames have:
- **Index**: Always present, integral part of the structure (like Series)
- **Label-based operations**: Operations align by index labels
- **Index is first-class**: Used for alignment, merging, and operations

**Example comparison**:

```r
# R - Row names are optional and separate
df <- data.frame(x=1:3, y=4:6)
rownames(df) <- c("a", "b", "c")  # Set row names separately
df["a", ]  # Access by row name
df[1, ]    # Access by position (1-indexed)
# Operations don't automatically align by row names
```

```python
# Pandas - Index is always present and integral
df = pd.DataFrame({'x': [1, 2, 3], 'y': [4, 5, 6]}, index=['a', 'b', 'c'])
df.loc['a']    # Access by index label
df.iloc[0]     # Access by position (0-indexed)
# Operations automatically align by index
```

### Creating a DataFrame

```python
# From a dictionary of lists
data = {
    'name': ['Alice', 'Bob', 'Charlie', 'David'],
    'age': [25, 30, 35, 28],
    'city': ['New York', 'London', 'Tokyo', 'Paris']
}
df = pd.DataFrame(data)
print(df)
# Output:
#       name  age      city
# 0    Alice   25  New York
# 1      Bob   30    London
# 2  Charlie   35     Tokyo
# 3    David   28     Paris

# From a list of dictionaries
data = [
    {'name': 'Alice', 'age': 25, 'city': 'New York'},
    {'name': 'Bob', 'age': 30, 'city': 'London'},
    {'name': 'Charlie', 'age': 35, 'city': 'Tokyo'}
]
df = pd.DataFrame(data)

# From a NumPy array
arr = np.random.randn(4, 3)
df = pd.DataFrame(arr, columns=['A', 'B', 'C'], index=['row1', 'row2', 'row3', 'row4'])

# From CSV file
df = pd.read_csv('data.csv')

# From Excel file
df = pd.read_excel('data.xlsx', sheet_name='Sheet1')

# From TSV file
df = pd.read_csv('data.tsv', sep='\t')
```

### Key DataFrame Operations

#### Viewing and Inspecting Data

**R vs Pandas comparison**:

| Operation | R | Pandas |
|-----------|---|--------|
| First rows | `head(df, 10)` | `df.head(10)` |
| Last rows | `tail(df, 10)` | `df.tail(10)` |
| Structure | `str(df)` | `df.info()` |
| Summary stats | `summary(df)` | `df.describe()` |
| Dimensions | `dim(df)` | `df.shape` |
| Column names | `colnames(df)` | `df.columns` |
| Row names | `rownames(df)` | `df.index` |
| Data types | `sapply(df, class)` | `df.dtypes` |
| Value counts | `table(df$col)` | `df['col'].value_counts()` |

```python
# First few rows
df.head()      # First 5 rows (default)
df.head(10)    # First 10 rows

# Last few rows
df.tail()      # Last 5 rows
df.tail(10)    # Last 10 rows

# Basic information
df.info()      # Data types, non-null counts, memory usage (like str() in R)
df.describe()  # Statistical summary (like summary() in R)
df.shape       # (rows, columns) - like dim() in R
df.columns     # Column names - like colnames() in R
df.index       # Index - like rownames() in R
df.dtypes      # Data types of each column - like sapply(df, class) in R

# Value counts for categorical columns
df['city'].value_counts()  # Like table(df$city) in R
```

#### Selecting Data

**R vs Pandas selection comparison**:

| Operation | R | Pandas |
|-----------|---|--------|
| Single column | `df$name` or `df[["name"]]` | `df['name']` or `df.name` |
| Multiple columns | `df[, c("name", "age")]` | `df[['name', 'age']]` |
| Single row (by position) | `df[1, ]` (1-indexed) | `df.iloc[0]` (0-indexed) |
| Single row (by name) | `df["rowname", ]` | `df.loc["rowname"]` |
| Row range (by position) | `df[1:3, ]` (1-indexed, inclusive) | `df.iloc[0:3]` (0-indexed, exclusive end) |
| Row range (by name) | `df["a":"c", ]` (inclusive) | `df.loc["a":"c"]` (inclusive) |
| Specific cell (by position) | `df[1, 2]` (1-indexed) | `df.iloc[0, 1]` (0-indexed) |
| Specific cell (by name) | `df["row", "col"]` | `df.loc["row", "col"]` |
| Boolean filtering | `df[df$age > 30, ]` | `df[df['age'] > 30]` |
| Multiple conditions | `df[df$age > 30 & df$city == "Tokyo", ]` | `df[(df['age'] > 30) & (df['city'] == 'Tokyo')]` |
| Query-like | `subset(df, age > 30 & city == "Tokyo")` | `df.query('age > 30 and city == "Tokyo"')` |

```python
# Select a column (returns Series)
df['name']        # Like df$name or df[["name"]] in R
df.name           # Alternative syntax (like df$name)

# Select multiple columns (returns DataFrame)
df[['name', 'age']]  # Like df[, c("name", "age")] in R

# Select rows by index label and/or column index
df.loc[0]           # First row (by label) - like df[1, ] in R (if index is 0)
df.loc[0:2]         # Rows 0 to 2 (inclusive) - like df[1:3, ] in R
df.loc[0:2, 'name'] # Rows 0-2, column 'name' - like df[1:3, "name"] in R

# Select rows by position (0-indexed!)
df.iloc[0]          # First row - like df[1, ] in R (but 0-indexed)
df.iloc[0:3]        # Rows 0, 1, 2 (exclusive end) - like df[1:3, ] in R
df.iloc[0:3, 0:2]   # Rows 0-2, columns 0-1 - like df[1:3, 1:2] in R

# Boolean indexing
df[df['age'] > 30]              # Rows where age > 30 - like df[df$age > 30, ] in R
df[(df['age'] > 30) & (df['city'] == 'Tokyo')]  # Multiple conditions - like df[df$age > 30 & df$city == "Tokyo", ] in R

# Query method (alternative to boolean indexing) - like subset() in R
df.query('age > 30 and city == "Tokyo"')  # Like subset(df, age > 30 & city == "Tokyo") in R
```

#### Understanding .loc vs .iloc

`.loc` and `.iloc` are two primary methods for selecting data from DataFrames. Understanding their differences is crucial for effective data manipulation.

**Key Differences**:

| Feature | `.loc` | `.iloc` |
|---------|--------|---------|
| **Selection by** | Index labels (names) | Integer positions |
| **Slicing behavior** | Inclusive (includes end) | Exclusive (excludes end) |
| **Works with** | Any index type (string, integer, date, etc.) | Only integer positions |
| **Use case** | When you know the index labels | When you know the positions |

**Detailed Comparison**:

```python
# Sample DataFrame with custom index
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'age': [25, 30, 35, 28, 32],
    'city': ['NYC', 'LA', 'NYC', 'LA', 'NYC']
}, index=['a', 'b', 'c', 'd', 'e'])

# .loc - Label-based selection
# Uses index labels (names), slicing is INCLUSIVE
df.loc['a']              # Row with index 'a'
df.loc['a':'c']          # Rows 'a', 'b', 'c' (INCLUSIVE - includes 'c')
df.loc['a', 'name']      # Value at row 'a', column 'name'
df.loc['a':'c', 'name']  # Rows 'a' to 'c', column 'name'
df.loc[['a', 'c'], ['name', 'age']]  # Specific rows and columns

# .iloc - Position-based selection
# Uses integer positions, slicing is EXCLUSIVE (like Python lists)
df.iloc[0]               # First row (position 0)
df.iloc[0:3]             # Rows 0, 1, 2 (EXCLUSIVE - excludes position 3)
df.iloc[0, 0]            # Value at row 0, column 0
df.iloc[0:3, 0:2]        # Rows 0-2, columns 0-1
df.iloc[[0, 2], [0, 1]]  # Specific rows and columns by position

# Important: Slicing behavior difference
df.loc['a':'c']   # Returns 3 rows: 'a', 'b', 'c' (INCLUSIVE)
df.iloc[0:3]      # Returns 3 rows: positions 0, 1, 2 (EXCLUSIVE, like Python)

# With integer index - be careful!
df_int = pd.DataFrame({'A': [1, 2, 3, 4, 5]}, index=[10, 20, 30, 40, 50])

# .loc uses the index labels (10, 20, 30, etc.)
df_int.loc[10:30]  # Returns rows with index 10, 20, 30 (INCLUSIVE)

# .iloc uses positions (0, 1, 2, etc.)
df_int.iloc[0:3]   # Returns rows at positions 0, 1, 2 (EXCLUSIVE)
# This is different from df_int.loc[10:30]!

# Setting values
df.loc['a', 'age'] = 26        # Set value using label
df.iloc[0, 1] = 26             # Set value using position

# Boolean indexing with .loc
df.loc[df['age'] > 30, 'name']  # Select 'name' column where age > 30
df.loc[df['age'] > 30, ['name', 'city']]  # Multiple columns

# Setting with conditions
df.loc[df['age'] > 30, 'salary'] = 50000  # Set salary where age > 30
```

**When to use `.loc`**:
- You know the index labels (names)
- Working with named/indexed data
- Need inclusive slicing behavior
- Setting values based on labels
- Boolean indexing with conditions

**When to use `.iloc`**:
- You know the integer positions
- Working with positional data
- Need standard Python slicing (exclusive end)
- Iterating through rows/columns by position
- When index labels are not meaningful

**Common Pitfalls**:

```python
# Pitfall 1: Confusing .loc and .iloc with integer index
df = pd.DataFrame({'A': [1, 2, 3]}, index=[10, 20, 30])

# This uses index labels (10, 20, 30)
df.loc[10:30]  # Returns all 3 rows

# This uses positions (0, 1, 2)
df.iloc[0:3]   # Returns all 3 rows, but conceptually different!

# Pitfall 2: Slicing behavior
df = pd.DataFrame({'A': [1, 2, 3, 4, 5]}, index=['a', 'b', 'c', 'd', 'e'])

df.loc['a':'c']   # Returns 3 rows: 'a', 'b', 'c' (INCLUSIVE)
df.iloc[0:3]      # Returns 3 rows: positions 0, 1, 2 (EXCLUSIVE)

# To get same result with .iloc, use:
df.iloc[0:3]      # Positions 0, 1, 2 (excludes 3)

# Pitfall 3: Using .loc with integer positions when index is not integer
df = pd.DataFrame({'A': [1, 2, 3]}, index=['x', 'y', 'z'])
# df.loc[0]  # ERROR! Index '0' doesn't exist
df.iloc[0]   # Correct - uses position
```

**Best Practices**:
1. Use `.loc` when working with meaningful index labels
2. Use `.iloc` when working with positions or iterating
3. Be aware of slicing behavior differences
4. For boolean indexing, prefer `.loc` for clarity
5. When in doubt with integer index, use `.iloc` to avoid confusion

#### Modifying Data

```python
# Add new column
df['salary'] = [50000, 60000, 70000, 55000]

# Modify existing column
df['age'] = df['age'] + 1  # Add 1 to all ages

# Rename columns
df.rename(columns={'name': 'full_name', 'age': 'years'}, inplace=True)

# Drop columns
df.drop('city', axis=1)           # Returns new DataFrame
df.drop('city', axis=1, inplace=True)  # Modifies in place

# Drop rows
df.drop(0)  # Drop row with index 0
df.drop([0, 2])  # Drop multiple rows

# Set index: column named 'name' becomes index
df.set_index('name', inplace=True)

# Reset index: revert the above operation
df.reset_index(inplace=True)
```

#### Data Cleaning

**R vs Pandas data cleaning comparison**:

| Operation | R | Pandas |
|-----------|---|--------|
| Check for NA | `is.na(df)` | `df.isna()` or `df.isnull()` |
| Drop rows with NA | `df[complete.cases(df), ]` | `df.dropna()` |
| Drop columns with NA | `df[, colSums(is.na(df)) == 0]` | `df.dropna(axis=1)` |
| Fill NA | `df[is.na(df)] <- 0` | `df.fillna(0)` |
| Fill with mean | `df$col[is.na(df$col)] <- mean(df$col, na.rm=TRUE)` | `df.fillna(df.mean())` |
| Remove duplicates | `df[!duplicated(df), ]` | `df.drop_duplicates()` |
| Remove duplicates by column | `df[!duplicated(df$col), ]` | `df.drop_duplicates(subset=['col'])` |
| Type conversion | `as.numeric(df$col)` | `df['col'].astype(float)` |
| Date conversion | `as.Date(df$date)` | `pd.to_datetime(df['date'])` |

```python
# Handle missing values
df.isna()           # Check for missing values - like is.na(df) in R
df.isnull()         # Same as isna()
df.dropna()         # Drop rows with any missing values - like df[complete.cases(df), ] in R
df.dropna(axis=1)   # Drop columns with any missing values
df.fillna(0)        # Fill missing values with 0 - like df[is.na(df)] <- 0 in R
df.fillna(df.mean())  # Fill with mean - like df$col[is.na(df$col)] <- mean(df$col, na.rm=TRUE) in R

# Remove duplicates
df.drop_duplicates()  # Like df[!duplicated(df), ] in R
df.drop_duplicates(subset=['name'])  # Based on specific columns - like df[!duplicated(df$name), ] in R

# Data type conversion
df['age'] = df['age'].astype(float)  # Like as.numeric(df$age) in R
df['date'] = pd.to_datetime(df['date'])  # Like as.Date(df$date) in R
```

#### String Operations

Pandas provides powerful string manipulation through the `.str` accessor. This is essential for cleaning and transforming text data.

**For R users**: Pandas string operations are similar to R's stringr package, but use the `.str` accessor pattern.

**R equivalent (using stringr)**:
```r
library(stringr)
# R string operations
str_to_upper(df$name)        # Convert to uppercase
str_to_lower(df$name)        # Convert to lowercase
str_length(df$name)          # String length
str_trim(df$name)            # Remove whitespace
str_split(df$name, " ")      # Split strings
str_replace(df$email, "@", "[at]")  # Replace
str_detect(df$email, "gmail")  # Contains pattern
```

**Pandas equivalent**:
```python
# Pandas string operations (using .str accessor)
df['name'].str.upper()       # Convert to uppercase
df['name'].str.lower()       # Convert to lowercase
df['name'].str.len()         # String length
df['name'].str.strip()       # Remove whitespace
df['name'].str.split(' ')    # Split strings
df['email'].str.replace('@', '[at]')  # Replace
df['email'].str.contains('gmail')  # Contains pattern
```

**Basic string operations**:

```python
# Sample data
df = pd.DataFrame({
    'name': ['Alice Smith', 'Bob Johnson', 'Charlie Brown'],
    'email': ['alice@email.com', 'BOB@EMAIL.COM', 'charlie@email.com'],
    'phone': ['123-456-7890', '234-567-8901', '345-678-9012']
})

# Case conversion
df['name'].str.upper()      # Convert to uppercase
df['name'].str.lower()        # Convert to lowercase
df['name'].str.title()      # Title case (first letter of each word)
df['name'].str.capitalize() # Capitalize first letter only

# String length
df['name'].str.len()        # Length of each string

# Strip whitespace
df['name'].str.strip()      # Remove leading/trailing whitespace
df['name'].str.lstrip()    # Remove leading whitespace
df['name'].str.rstrip()    # Remove trailing whitespace

# Split strings
df['name'].str.split(' ')   # Split by space, returns list
df['name'].str.split(' ', expand=True)  # Split into separate columns
df['name'].str.split(' ', n=1)  # Split into max n parts

# Extract parts
df['name'].str[0]           # First character
df['name'].str[:5]          # First 5 characters
df['name'].str[-5:]         # Last 5 characters

# Replace
df['email'].str.replace('@', '[at]')  # Replace substring
df['phone'].str.replace('-', '')     # Remove dashes

# Contains, startswith, endswith
df['email'].str.contains('gmail')    # Boolean: contains substring
df['email'].str.startswith('alice')  # Boolean: starts with
df['email'].str.endswith('.com')      # Boolean: ends with

# Count occurrences
df['name'].str.count('a')  # Count occurrences of substring

# Find position
df['email'].str.find('@')  # Position of first occurrence (-1 if not found)
df['email'].str.rfind('@') # Position of last occurrence
```

**Regular expressions**:

```python
# Extract patterns
df['email'].str.extract(r'(\w+)@(\w+)\.(\w+)')  # Extract groups
# Returns DataFrame with columns for each group

# Extract all matches
df['text'].str.extractall(r'(\d+)')  # Extract all numbers

# Replace with regex
df['phone'].str.replace(r'\D', '')  # Remove all non-digits

# Match pattern
df['email'].str.match(r'^[a-z]+@')  # Boolean: matches pattern from start

# Contains pattern
df['text'].str.contains(r'\d+')  # Contains digits
```

**String concatenation**:

```python
# Concatenate columns
df['full_info'] = df['name'].str.cat(df['email'], sep=' | ')

# Concatenate with separator
df['name'].str.cat(sep=', ')  # Join all values with separator

# Concatenate multiple columns
df['full'] = df[['name', 'email']].apply(lambda x: ' | '.join(x), axis=1)
```

**Practical examples**:

```python
# Extract first and last name
df[['first_name', 'last_name']] = df['name'].str.split(' ', n=1, expand=True)

# Normalize email to lowercase
df['email'] = df['email'].str.lower()

# Extract domain from email
df['domain'] = df['email'].str.extract(r'@(\w+\.\w+)')

# Clean phone numbers (remove non-digits)
df['phone_clean'] = df['phone'].str.replace(r'\D', '')

# Check if email is valid format
df['valid_email'] = df['email'].str.match(r'^[\w\.-]+@[\w\.-]+\.\w+$')

# Pad strings
df['id'].str.zfill(5)  # Zero-pad to 5 digits: '123' -> '00123'
df['name'].str.pad(width=20, side='right', fillchar='-')  # Pad with dashes
```

**Important notes**:
- String operations return Series (or DataFrame for some operations)
- Operations are vectorized and efficient
- Missing values (NaN) propagate through string operations
- Use `na=False` parameter to handle NaN in boolean operations: `df['col'].str.contains('text', na=False)`

#### DateTime Operations

Working with dates and times is crucial for time series analysis. Pandas provides comprehensive datetime functionality.

**For R users**: Pandas datetime operations are similar to R's lubridate package, with some syntax differences.

**R equivalent (using lubridate)**:
```r
library(lubridate)
# R datetime operations
df$date <- as.Date(df$date)           # Convert to date
df$date <- ymd(df$date)                # Parse date
year(df$date)                          # Extract year
month(df$date)                         # Extract month
day(df$date)                           # Extract day
df$date + days(7)                      # Add days
df$date %--% other_date                # Date interval
```

**Pandas equivalent**:
```python
# Pandas datetime operations
df['date'] = pd.to_datetime(df['date'])  # Convert to datetime
df['date'].dt.year                       # Extract year
df['date'].dt.month                      # Extract month
df['date'].dt.day                        # Extract day
df['date'] + pd.Timedelta(days=7)       # Add days
df['date'] - other_date                 # Date difference
```

**Creating datetime objects**:

```python
# Convert to datetime
df['date'] = pd.to_datetime(df['date'])
df['date'] = pd.to_datetime(df['date'], format='%Y-%m-%d')  # Specify format
df['date'] = pd.to_datetime(df['date'], errors='coerce')  # Convert errors to NaT

# Create datetime from components
pd.to_datetime({'year': [2024], 'month': [1], 'day': [15]})

# Current timestamp
pd.Timestamp.now()
pd.Timestamp.today()

# Create date range
pd.date_range('2024-01-01', periods=10, freq='D')  # Daily
pd.date_range('2024-01-01', '2024-01-31', freq='D')
```

**DateTimeIndex**:

```python
# Set datetime as index
df.set_index('date', inplace=True)

# Access by date
df.loc['2024-01-15']           # Specific date
df.loc['2024-01']              # Entire month
df.loc['2024-01-15':'2024-01-20']  # Date range

# Partial string indexing
df.loc['2024']                  # Entire year
df.loc['2024-01':'2024-03']     # Quarter
```

**Extracting datetime components**:

```python
df['date'].dt.year              # Year
df['date'].dt.month             # Month (1-12)
df['date'].dt.day               # Day of month
df['date'].dt.dayofweek         # Day of week (0=Monday)
df['date'].dt.day_name()        # Day name ('Monday', 'Tuesday', etc.)
df['date'].dt.quarter           # Quarter (1-4)
df['date'].dt.week              # Week number
df['date'].dt.is_month_start    # Boolean: is first day of month
df['date'].dt.is_month_end      # Boolean: is last day of month
df['date'].dt.is_quarter_start  # Boolean: is first day of quarter
df['date'].dt.is_year_start     # Boolean: is first day of year

# Time components (if datetime includes time)
df['datetime'].dt.hour          # Hour (0-23)
df['datetime'].dt.minute         # Minute
df['datetime'].dt.second         # Second
df['datetime'].dt.time           # Time component only
```

**Date arithmetic**:

```python
# Date differences
df['date'] - pd.Timestamp('2024-01-01')  # Timedelta
(df['date'] - pd.Timestamp('2024-01-01')).dt.days  # Days difference

# Add/subtract time
df['date'] + pd.Timedelta(days=7)        # Add 7 days
df['date'] + pd.Timedelta(weeks=2)       # Add 2 weeks
df['date'] + pd.Timedelta(months=1)      # Add 1 month (approximate)
df['date'] - pd.Timedelta(hours=24)      # Subtract 24 hours

# Date offsets (more precise)
from pandas.tseries.offsets import Day, MonthEnd, BDay
df['date'] + Day(7)                      # Add 7 days
df['date'] + MonthEnd()                  # Move to end of month
df['date'] + BDay(5)                     # Add 5 business days
```

**Formatting dates**:

```python
# Convert to string
df['date'].dt.strftime('%Y-%m-%d')      # Format as string
df['date'].dt.strftime('%B %d, %Y')     # 'January 15, 2024'
df['date'].dt.strftime('%A, %B %d')    # 'Monday, January 15'

# Common format codes:
# %Y - 4-digit year, %y - 2-digit year
# %m - Month (01-12), %B - Full month name, %b - Abbreviated month
# %d - Day (01-31), %A - Full weekday, %a - Abbreviated weekday
# %H - Hour (00-23), %M - Minute, %S - Second
```

**Resampling (time-based grouping)**:

**For R users**: Pandas `resample()` is similar to R's time-based aggregation using `lubridate` and `dplyr`.

**R equivalent**:
```r
library(dplyr)
library(lubridate)
# R time-based resampling
df %>% 
  mutate(date = as.Date(date)) %>%
  group_by(week = floor_date(date, "week")) %>%
  summarise(mean_value = mean(value))
# Or using aggregate with cut.Date
aggregate(value ~ cut(date, "month"), data=df, FUN=mean)
```

**Pandas equivalent**:
```python
# Set datetime index
df.set_index('date', inplace=True)

# Resample to different frequencies
df.resample('D').mean()         # Daily mean
df.resample('W').sum()          # Weekly sum
df.resample('M').mean()          # Monthly mean
df.resample('Q').mean()          # Quarterly mean
df.resample('Y').sum()          # Yearly sum

# Common frequency aliases:
# 'D' - Daily, 'W' - Weekly, 'M' - Month end, 'MS' - Month start
# 'Q' - Quarter end, 'QS' - Quarter start, 'Y' - Year end, 'YS' - Year start
# 'H' - Hourly, 'T' or 'min' - Minute, 'S' - Second

# Resample with different methods
df.resample('D').agg({
    'value': ['mean', 'sum', 'count'],
    'price': 'last'  # Last value in period
})

# Resample with label and convention
df.resample('M', label='right', convention='end').mean()
```

**Rolling windows (time-based)**:

```python
# Rolling mean
df['value'].rolling(window=7).mean()        # 7-day rolling mean
df['value'].rolling(window='30D').mean()   # 30-day rolling mean (datetime index)

# Rolling statistics
df['value'].rolling(7).sum()               # Rolling sum
df['value'].rolling(7).std()                # Rolling standard deviation
df['value'].rolling(7).min()               # Rolling minimum
df['value'].rolling(7).max()               # Rolling maximum

# Expanding window
df['value'].expanding().mean()              # Expanding mean (cumulative)
df['value'].expanding().sum()               # Cumulative sum
```

**Practical examples**:

```python
# Calculate age from birthdate
df['age'] = (pd.Timestamp.now() - df['birthdate']).dt.days / 365.25

# Extract year-month for grouping
df['year_month'] = df['date'].dt.to_period('M')

# Find records from last 30 days
recent = df[df['date'] >= pd.Timestamp.now() - pd.Timedelta(days=30)]

# Group by month
df.groupby(df['date'].dt.month).sum()

# Calculate days between dates
df['days_diff'] = (df['end_date'] - df['start_date']).dt.days

# Business days between dates
from pandas.tseries.offsets import BDay
business_days = len(pd.bdate_range(df['start_date'], df['end_date']))
```

#### Grouping and Aggregation

**For R users**: Pandas `groupby()` is similar to R's `dplyr::group_by()` and `aggregate()` functions.

**R equivalent (using dplyr)**:
```r
library(dplyr)
# R grouping and aggregation
df %>% group_by(city) %>% summarise(mean_age = mean(age))
df %>% group_by(city) %>% summarise(
    mean_age = mean(age),
    sum_salary = sum(salary),
    count = n()
)
df %>% group_by(city, department) %>% summarise_all(mean)
aggregate(salary ~ city + department, data=df, FUN=mean)  # Base R
```

**Pandas equivalent**:
```python
# Group by
df.groupby('city')['age'].mean()  # Mean age by city
df.groupby('city').agg({
    'age': 'mean',
    'salary': ['mean', 'sum', 'count']
})

# Multiple groupby columns
df.groupby(['city', 'department']).mean()

# Pivot tables
df.pivot_table(values='salary', index='city', columns='department', aggfunc='mean')
```

#### Pivot Tables

`pivot_table()` is a powerful method for reshaping and aggregating data. It creates a spreadsheet-style pivot table that summarizes data by grouping and aggregating values.

**For R users**: `pivot_table()` is similar to R's **two-way table** (contingency table) created with `table()` or `xtabs()`, but more flexible:
- **R `table()`**: Creates frequency counts (counts only)
- **R `xtabs()`**: Creates cross-tabulations with formulas (counts by default, but can aggregate)
- **Pandas `pivot_table()`**: More flexible - can aggregate with any function (mean, sum, count, etc.)

**R two-way table example**:
```r
# R - Create two-way table (counts)
table(df$city, df$department)

# R - Cross-tabulation with aggregation
xtabs(salary ~ city + department, data=df)  # Sum by default
aggregate(salary ~ city + department, data=df, FUN=mean)  # Mean
```

**Pandas equivalent**:
```python
# Python/Pandas - Count (like R table())
df.pivot_table(values='salary', index='city', columns='department', aggfunc='count')

# Python/Pandas - Mean (like R aggregate())
df.pivot_table(values='salary', index='city', columns='department', aggfunc='mean')

# Python/Pandas - Sum (like R xtabs())
df.pivot_table(values='salary', index='city', columns='department', aggfunc='sum')
```

**Basic syntax**:
```python
df.pivot_table(
    values=None,      # Column(s) to aggregate
    index=None,       # Column(s) to use as row index
    columns=None,     # Column(s) to use as column headers
    aggfunc='mean',   # Aggregation function(s)
    fill_value=None,  # Value to replace missing values
    margins=False,    # Add row/column totals
    dropna=True       # Drop columns with all NaN
)
```

**Key parameters**:
- **`values`**: Column(s) to aggregate (the data you want to summarize)
- **`index`**: Column(s) that become row labels (vertical grouping)
- **`columns`**: Column(s) that become column headers (horizontal grouping)
- **`aggfunc`**: Aggregation function - can be string ('mean', 'sum', 'count', etc.) or list/dict of functions
- **`fill_value`**: Value to replace NaN in the result
- **`margins`**: Add row/column totals (like Excel pivot tables)
- **`dropna`**: Whether to drop columns with all NaN values

**Examples**:

```python
# Sample data
df = pd.DataFrame({
    'city': ['NYC', 'NYC', 'LA', 'LA', 'NYC', 'LA'],
    'department': ['Sales', 'IT', 'Sales', 'IT', 'Sales', 'IT'],
    'salary': [50000, 60000, 55000, 65000, 52000, 62000],
    'bonus': [5000, 6000, 5500, 6500, 5200, 6200]
})

# Basic pivot: mean salary by city and department
df.pivot_table(values='salary', index='city', columns='department', aggfunc='mean')
# Output:
# department      IT    Sales
# city
# LA           63500   55000
# NYC          60000   51000

# Multiple aggregation functions
df.pivot_table(values='salary', index='city', columns='department', 
               aggfunc=['mean', 'sum', 'count'])
# Creates multi-level columns with mean, sum, and count

# Multiple values
df.pivot_table(values=['salary', 'bonus'], index='city', columns='department', 
               aggfunc='mean')
# Aggregates both salary and bonus columns

# Custom aggregation function
df.pivot_table(values='salary', index='city', columns='department', 
               aggfunc=lambda x: x.max() - x.min())  # Range

# Fill missing values
df.pivot_table(values='salary', index='city', columns='department', 
               aggfunc='mean', fill_value=0)

# Add margins (row and column totals)
df.pivot_table(values='salary', index='city', columns='department', 
               aggfunc='mean', margins=True)
# Output includes 'All' row and column with totals

# Multiple index columns
df.pivot_table(values='salary', index=['city', 'year'], columns='department', 
               aggfunc='mean')
# Creates hierarchical row index

# Multiple column levels
df.pivot_table(values='salary', index='city', 
               columns=['department', 'quarter'], aggfunc='mean')
# Creates hierarchical column index

# Dictionary of aggregation functions for different values
df.pivot_table(values=['salary', 'bonus'], index='city', columns='department',
               aggfunc={'salary': 'mean', 'bonus': 'sum'})
```

**Comparison with `pivot()`**:
- **`pivot()`**: Simple reshaping without aggregation (requires unique index-column pairs
- **`pivot_table()`**: Reshapes with aggregation (handles duplicate entries, more flexible)

```python
# pivot() - no aggregation, fails with duplicates
df.pivot(index='city', columns='department', values='salary')  # May fail if duplicates exist

# pivot_table() - handles duplicates with aggregation
df.pivot_table(values='salary', index='city', columns='department', aggfunc='mean')
```

**Common use cases**:
- Creating cross-tabulations
- Summarizing data by categories
- Preparing data for visualization
- Creating summary reports
- Analyzing relationships between categorical variables
```

#### Function Application: apply(), map(), and applymap()

Understanding when to use `apply()`, `map()`, and `applymap()` is crucial for efficient data transformation.

**For R users**: These functions are similar to R's `apply()`, `sapply()`, `lapply()`, and `Map()` functions.

**R equivalent**:
```r
# R apply functions
apply(df, 2, mean)              # Apply to columns (axis=1 in R)
apply(df, 1, sum)                # Apply to rows (axis=2 in R)
sapply(df$col, function(x) x^2)  # Apply to vector
lapply(df, mean)                 # Apply to each column
Map(function(x) x*2, df$col)     # Element-wise mapping
```

**Pandas equivalent**:
```python
# Pandas apply functions
df.apply(np.mean)                # Apply to columns (axis=0, default)
df.apply(np.sum, axis=1)         # Apply to rows (axis=1)
df['col'].apply(lambda x: x**2)   # Apply to Series
df.apply(lambda x: x.mean())      # Apply to each column
df['col'].map(lambda x: x*2)     # Element-wise mapping
```

**apply() - Apply function along axis**:

```python
# On Series: applies function to each element
s = pd.Series([1, 2, 3, 4])
s.apply(lambda x: x**2)  # Square each element
s.apply(np.sqrt)         # Square root of each element

# On DataFrame: applies function along axis (default: axis=0, columns)
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})

# Apply to each column (axis=0, default)
df.apply(np.mean)        # Mean of each column
df.apply(lambda x: x.max() - x.min())  # Range of each column

# Apply to each row (axis=1)
df.apply(np.sum, axis=1)  # Sum of each row
df.apply(lambda row: row['A'] + row['B'], axis=1)  # Custom row operation

# Apply with multiple return values (returns DataFrame)
def stats(x):
    return pd.Series([x.mean(), x.std()], index=['mean', 'std'])
df.apply(stats)  # Returns DataFrame with mean and std for each column

# Apply with result_type
df.apply(lambda x: [x.min(), x.max()], axis=1, result_type='expand')
# Expands list into separate columns
```

**map() - Element-wise mapping for Series**:

```python
# Map values using a dictionary
s = pd.Series(['a', 'b', 'c', 'a'])
mapping = {'a': 1, 'b': 2, 'c': 3}
s.map(mapping)  # Maps each value: a->1, b->2, c->3

# Map using a function
s.map(str.upper)  # Convert to uppercase
s.map(lambda x: x.upper())  # Same as above

# Map with Series (aligns by index)
s1 = pd.Series([1, 2, 3], index=['a', 'b', 'c'])
s2 = pd.Series(['one', 'two', 'three'], index=['a', 'b', 'c'])
s1.map(s2)  # Maps 1->'one', 2->'two', 3->'three'

# Map with NaN handling
s.map(mapping, na_action='ignore')  # Ignore NaN values
```

**applymap() - Element-wise function for DataFrame (deprecated)**:

```python
# applymap() is deprecated, use map() instead
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})

# Old way (deprecated)
# df.applymap(lambda x: x**2)

# New way (use map())
df.map(lambda x: x**2)  # Square each element
df.map(str)             # Convert each element to string
```

**Key differences**:

| Method | Works On | Purpose | Returns |
|--------|----------|---------|---------|
| **apply()** | Series or DataFrame | Apply function along axis | Series or DataFrame |
| **map()** | Series | Element-wise mapping/transformation | Series |
| **map()** (DataFrame) | DataFrame | Element-wise (replaces applymap) | DataFrame |

**When to use each**:

```python
# Use apply() when:
# - Aggregating along axis (mean, sum, etc.)
df.apply(np.mean)  # Mean of each column

# - Complex row/column operations
df.apply(lambda row: row['A'] * row['B'], axis=1)  # Row-wise calculation

# - Need multiple return values
df.apply(lambda x: pd.Series([x.min(), x.max()]))

# Use map() when:
# - Simple value mapping (dictionary lookup)
df['category'].map({'A': 1, 'B': 2, 'C': 3})

# - Element-wise transformation on Series
df['name'].map(str.upper)

# - Element-wise transformation on DataFrame
df.map(lambda x: x * 2)  # Double each value
```

**Performance considerations**:

```python
# Vectorized operations are faster than apply()
# Slow:
df['result'] = df.apply(lambda row: row['A'] + row['B'], axis=1)

# Fast:
df['result'] = df['A'] + df['B']

# Use apply() only when vectorization isn't possible
```

#### Window Functions: rolling(), expanding(), and ewm()

Window functions are essential for time series analysis and moving calculations.

**For R users**: Pandas window functions are similar to R's `zoo` and `TTR` packages for rolling calculations.

**R equivalent (using zoo and TTR)**:
```r
library(zoo)
library(TTR)
# R rolling functions
rollmean(df$value, k=7)          # 7-period rolling mean
rollsum(df$value, k=7)           # 7-period rolling sum
rollapply(df$value, 7, sd)       # 7-period rolling std
EMA(df$value, n=7)               # Exponentially weighted moving average
```

**Pandas equivalent**:
```python
# Pandas rolling functions
df['value'].rolling(window=7).mean()   # 7-period rolling mean
df['value'].rolling(window=7).sum()     # 7-period rolling sum
df['value'].rolling(window=7).std()     # 7-period rolling std
df['value'].ewm(span=7).mean()         # Exponentially weighted moving average
```

**rolling() - Rolling window calculations**:

```python
# Basic rolling window
df['value'].rolling(window=3).mean()      # 3-period rolling mean
df['value'].rolling(window=7).sum()       # 7-period rolling sum
df['value'].rolling(window=5).std()       # 5-period rolling std

# Rolling window with datetime index
df.set_index('date', inplace=True)
df['value'].rolling(window='7D').mean()   # 7-day rolling mean
df['value'].rolling(window='30D').sum()   # 30-day rolling sum
df['value'].rolling(window='1M').mean()   # 1-month rolling mean

# Window types
df['value'].rolling(7, center=True).mean()  # Centered window
df['value'].rolling(7, min_periods=3).mean()  # Minimum periods required

# Multiple statistics
df['value'].rolling(7).agg(['mean', 'std', 'min', 'max'])

# Rolling on multiple columns
df[['A', 'B']].rolling(7).mean()
```

**expanding() - Expanding window (cumulative)**:

```python
# Expanding mean (cumulative mean)
df['value'].expanding().mean()    # Running mean from start
df['value'].expanding().sum()     # Cumulative sum
df['value'].expanding().std()     # Expanding standard deviation
df['value'].expanding().min()    # Running minimum
df['value'].expanding().max()     # Running maximum

# Expanding with minimum periods
df['value'].expanding(min_periods=5).mean()  # Start after 5 periods
```

**ewm() - Exponentially weighted moving**:

```python
# Exponentially weighted moving average
df['value'].ewm(span=7).mean()        # 7-period EWMA
df['value'].ewm(halflife=3).mean()   # Half-life of 3 periods
df['value'].ewm(alpha=0.3).mean()    # Smoothing factor alpha

# Different adjustment methods
df['value'].ewm(span=7, adjust=True).mean()   # Adjust for bias (default)
df['value'].ewm(span=7, adjust=False).mean()  # No adjustment (faster)

# EWM statistics
df['value'].ewm(span=7).std()   # Exponentially weighted std
df['value'].ewm(span=7).var()   # Exponentially weighted variance
```

**Practical examples**:

```python
# Moving average crossover strategy
df['ma_short'] = df['price'].rolling(5).mean()
df['ma_long'] = df['price'].rolling(20).mean()
df['signal'] = (df['ma_short'] > df['ma_long']).astype(int)

# Rolling correlation
df['A'].rolling(30).corr(df['B'])  # 30-period rolling correlation

# Percentage change over rolling window
df['pct_change'] = df['value'].rolling(7).apply(
    lambda x: (x.iloc[-1] - x.iloc[0]) / x.iloc[0]
)

# Z-score (standardization) over rolling window
df['zscore'] = (df['value'] - df['value'].rolling(30).mean()) / \
                df['value'].rolling(30).std()

# Maximum drawdown (rolling)
df['rolling_max'] = df['value'].expanding().max()
df['drawdown'] = (df['value'] - df['rolling_max']) / df['rolling_max']

# Volatility (rolling standard deviation of returns)
df['returns'] = df['price'].pct_change()
df['volatility'] = df['returns'].rolling(30).std() * np.sqrt(252)  # Annualized
```

#### Data Reshaping: melt(), stack(), and unstack()

Reshaping data between wide and long formats is common in data analysis.

**For R users**: Pandas reshaping functions are similar to R's `tidyr` package functions.

**R equivalent (using tidyr)**:
```r
library(tidyr)
# R reshaping functions
pivot_longer(df, cols=c('Q1', 'Q2', 'Q3'), 
              names_to='quarter', values_to='sales')  # Wide to long
pivot_wider(df, names_from='quarter', values_from='sales')  # Long to wide
gather(df, key='quarter', value='sales', Q1:Q3)  # Wide to long (older syntax)
spread(df, key='quarter', value='sales')  # Long to wide (older syntax)
```

**Pandas equivalent**:
```python
# Pandas reshaping functions
df.melt(id_vars=['id'], value_vars=['Q1', 'Q2', 'Q3'],
        var_name='quarter', value_name='sales')  # Wide to long
df.pivot_table(index='id', columns='quarter', values='sales')  # Long to wide
df.stack()  # Stack columns to index
df.unstack()  # Unstack index to columns
```

**melt() - Convert wide to long format**:

```python
# Sample wide data
df = pd.DataFrame({
    'id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie'],
    'Q1': [100, 200, 150],
    'Q2': [110, 210, 160],
    'Q3': [120, 220, 170]
})

# Melt: convert columns to rows
df_melted = df.melt(
    id_vars=['id', 'name'],      # Columns to keep as identifiers
    value_vars=['Q1', 'Q2', 'Q3'],  # Columns to melt (optional)
    var_name='quarter',          # Name for variable column
    value_name='sales'           # Name for value column
)

# Result:
#    id     name quarter  sales
# 0   1    Alice      Q1    100
# 1   2      Bob      Q1    200
# 2   3  Charlie      Q1    150
# 3   1    Alice      Q2    110
# ...

# Melt all columns except id_vars
df.melt(id_vars=['id', 'name'], var_name='quarter', value_name='sales')
```

**stack() - Pivot columns to index levels**:

```python
# Stack: moves column level to index level
df = pd.DataFrame({
    'A': [1, 2, 3],
    'B': [4, 5, 6]
}, index=['x', 'y', 'z'])

df_stacked = df.stack()  # Creates MultiIndex Series
# Result:
# x  A    1
#    B    4
# y  A    2
#    B    5
# z  A    3
#    B    6

# Stack specific level (for MultiIndex columns)
df.columns = pd.MultiIndex.from_tuples([('X', 'A'), ('X', 'B')])
df.stack(level=0)  # Stack first level
```

**unstack() - Pivot index levels to columns**:

```python
# Unstack: moves index level to column level
df = pd.DataFrame({
    'value': [1, 2, 3, 4, 5, 6]
}, index=pd.MultiIndex.from_tuples([
    ('x', 'A'), ('x', 'B'),
    ('y', 'A'), ('y', 'B'),
    ('z', 'A'), ('z', 'B')
], names=['level1', 'level2']))

df_unstacked = df.unstack()  # Moves level2 to columns
# Result:
#        value
# level2    A    B
# level1
# x         1    2
# y         3    4
# z         5    6

# Unstack specific level
df.unstack(level='level2')
df.unstack(level=1)  # By position

# Unstack with fill_value
df.unstack(fill_value=0)  # Fill NaN with 0
```

**Practical examples**:

```python
# Wide to long: Multiple measurements per subject
df_wide = pd.DataFrame({
    'subject': ['A', 'B', 'C'],
    'baseline': [10, 20, 15],
    'week1': [12, 22, 17],
    'week2': [14, 24, 19]
})

df_long = df_wide.melt(
    id_vars='subject',
    value_vars=['baseline', 'week1', 'week2'],
    var_name='timepoint',
    value_name='measurement'
)

# Long to wide: pivot_table alternative
df_long.pivot_table(
    index='subject',
    columns='timepoint',
    values='measurement'
)

# Stack/unstack for hierarchical data
df = pd.DataFrame({
    'Q1': {'A': 100, 'B': 200},
    'Q2': {'A': 110, 'B': 210}
})
df_stacked = df.stack()  # Wide to long
df_unstacked = df_stacked.unstack()  # Long to wide
```

#### Merging and Joining

**For R users**: Pandas merging is very similar to R's `merge()` and `dplyr::join_*()` functions.

**R equivalent (using dplyr and base R)**:
```r
library(dplyr)
# R merging
inner_join(df1, df2, by='key')    # Inner join
left_join(df1, df2, by='key')     # Left join
right_join(df1, df2, by='key')    # Right join
full_join(df1, df2, by='key')     # Outer join
merge(df1, df2, by='key')         # Inner join (base R, default)
merge(df1, df2, by='key', all.x=TRUE)   # Left join (base R)
merge(df1, df2, by='key', all.y=TRUE)   # Right join (base R)
merge(df1, df2, by='key', all=TRUE)     # Outer join (base R)
```

**Pandas equivalent**:
```python
# Merge DataFrames
df1 = pd.DataFrame({'key': ['A', 'B', 'C'], 'value1': [1, 2, 3]})
df2 = pd.DataFrame({'key': ['B', 'C', 'D'], 'value2': [4, 5, 6]})

# Inner join (default)
pd.merge(df1, df2, on='key')

# Left join
pd.merge(df1, df2, on='key', how='left')

# Right join
pd.merge(df1, df2, on='key', how='right')

# Outer join
pd.merge(df1, df2, on='key', how='outer')

# Concatenate
pd.concat([df1, df2], axis=0)  # Stack vertically
pd.concat([df1, df2], axis=1)  # Stack horizontally
```

#### Sorting

```python
# Sort by column
df.sort_values('age')                    # Ascending
df.sort_values('age', ascending=False)   # Descending
df.sort_values(['city', 'age'])          # Multiple columns

# Sort by index
df.sort_index()
```

#### Converting DataFrame to NumPy Array

Pandas DataFrames can be converted to NumPy arrays for use with NumPy operations or machine learning libraries.

```python
# Method 1: .values (legacy, still works but deprecated in favor of .to_numpy())
arr = df.values  # Returns NumPy array (may be object dtype if mixed types)

# Method 2: .to_numpy() (recommended - more explicit and flexible)
arr = df.to_numpy()  # Returns NumPy array
arr = df.to_numpy(dtype='float64')  # Specify data type
arr = df.to_numpy(na_value=0)  # Replace NaN with 0

# Convert specific columns to NumPy
arr = df[['age', 'salary']].to_numpy()  # Only selected columns

# Convert single column (Series) to NumPy
arr = df['age'].to_numpy()  # Returns 1D array
arr = df['age'].values  # Alternative (legacy)

# Important considerations:
# - Mixed data types: DataFrame with mixed types will result in object dtype array
# - Missing values: NaN values are preserved in the array (use na_value parameter)
# - Index and column names: Lost when converting to NumPy array
# - Memory: NumPy arrays are more memory-efficient for homogeneous numeric data

# Example with numeric DataFrame
df_numeric = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
arr = df_numeric.to_numpy()
print(arr)
# Output:
# [[1 4]
#  [2 5]
#  [3 6]]
print(type(arr))  # <class 'numpy.ndarray'>

# Example with mixed types (results in object array)
df_mixed = pd.DataFrame({'A': [1, 2, 3], 'B': ['x', 'y', 'z']})
arr = df_mixed.to_numpy()
print(arr.dtype)  # object (because of mixed types)
```

## Part 3: Plotting with Pandas

Pandas integrates seamlessly with Matplotlib and provides convenient plotting methods for quick data visualization.

### Basic Plotting

```python
import matplotlib.pyplot as plt

# Line plot
df['age'].plot(kind='line')
df.plot(x='name', y='age', kind='line')

# Bar plot
df['age'].plot(kind='bar')
df.plot(x='name', y='age', kind='bar')

# Horizontal bar plot
df.plot(x='name', y='age', kind='barh')

# Histogram
df['age'].plot(kind='hist', bins=10)

# Box plot
df['age'].plot(kind='box')

# Scatter plot
df.plot(x='age', y='salary', kind='scatter')

# Pie chart
df['city'].value_counts().plot(kind='pie')
```

### Advanced Plotting

```python
# Multiple plots
df[['age', 'salary']].plot(kind='line', subplots=True)

# Customize plots
ax = df['age'].plot(kind='bar', color='skyblue', figsize=(10, 6))
ax.set_title('Age Distribution')
ax.set_xlabel('Name')
ax.set_ylabel('Age')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Using Matplotlib directly with Pandas data
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
df['age'].plot(kind='hist', ax=axes[0, 0], title='Age Histogram')
df['salary'].plot(kind='box', ax=axes[0, 1], title='Salary Box Plot')
df.plot(x='age', y='salary', kind='scatter', ax=axes[1, 0], title='Age vs Salary')
df['city'].value_counts().plot(kind='bar', ax=axes[1, 1], title='City Counts')
plt.tight_layout()
plt.show()
```

### Integration with Seaborn

```python
import seaborn as sns

# Seaborn works directly with Pandas DataFrames
sns.boxplot(data=df, x='city', y='age')
sns.scatterplot(data=df, x='age', y='salary', hue='city')
sns.heatmap(df.corr(), annot=True)  # Correlation heatmap
sns.pairplot(df)  # Pairwise relationships
```

### Integration with Lets-Plot

[Lets-Plot](https://lets-plot.org/) is a Python library that provides a ggplot2-like API for data visualization. It's particularly useful for R users familiar with ggplot2, as it follows similar grammar-of-graphics principles.

**Installation**:
```bash
pip install lets-plot
```

**Basic usage with Pandas DataFrames**:
```python
from lets_plot import *
LetsPlot.setup_html()

# Scatter plot
ggplot(df) + geom_point(aes(x='age', y='salary', color='city'))

# Bar plot
ggplot(df) + geom_bar(aes(x='city', fill='city'), stat='count')

# Line plot
ggplot(df) + geom_line(aes(x='name', y='age', group=1))

# Histogram
ggplot(df) + geom_histogram(aes(x='age'), bins=10)

# Box plot
ggplot(df) + geom_boxplot(aes(x='city', y='age'))

# Faceting (like facet_wrap in ggplot2)
ggplot(df) + geom_point(aes(x='age', y='salary')) + facet_wrap('city')

# Multiple layers
ggplot(df) + \
    geom_point(aes(x='age', y='salary', color='city')) + \
    geom_smooth(aes(x='age', y='salary'), method='lm') + \
    labs(title='Age vs Salary by City', x='Age', y='Salary') + \
    theme_minimal()
```

**Key advantages of Lets-Plot**:
- **Grammar of graphics**: Familiar syntax for R/ggplot2 users
- **Interactive plots**: Built-in interactivity without additional libraries
- **Works with Pandas**: Direct integration with Pandas DataFrames
- **Publication quality**: High-quality plots suitable for publications
- **Layered approach**: Build complex plots by adding layers

**Comparison with other libraries**:
- **Matplotlib**: Lower-level, more control but verbose syntax
- **Seaborn**: Statistical visualizations, built on Matplotlib
- **Lets-Plot**: Grammar-of-graphics approach, similar to ggplot2 in R

**Example: Complex visualization with Lets-Plot**:
```python
from lets_plot import *
LetsPlot.setup_html()

# Create a comprehensive plot with multiple elements
(ggplot(df) +
 geom_point(aes(x='age', y='salary', color='city', size='bonus'), alpha=0.7) +
 geom_smooth(aes(x='age', y='salary'), method='loess', se=True) +
 scale_color_brewer(type='qual', palette='Set2') +
 labs(
     title='Salary Analysis by Age and City',
     x='Age (years)',
     y='Salary ($)',
     color='City',
     size='Bonus'
 ) +
 theme_minimal() +
 theme(plot_title=element_text(hjust=0.5))
)
```

**For R users**: If you're familiar with ggplot2, Lets-Plot provides a very similar API, making it easy to transition from R to Python for data visualization.

## Part 4: Practice Questions

### Beginner Level

**Question 1: Create and Manipulate Series**
Create a Series with the following data: [10, 20, 30, 40, 50] with index labels ['a', 'b', 'c', 'd', 'e']. Then:
- Select the value at index 'c'
- Multiply all values by 2
- Find the mean and standard deviation

**Solution:**
```python
s = pd.Series([10, 20, 30, 40, 50], index=['a', 'b', 'c', 'd', 'e'])
print(s['c'])           # 30
print(s * 2)            # Multiply by 2
print(s.mean())         # 30.0
print(s.std())          # Standard deviation
```

**Question 2: Basic DataFrame Operations**
Given the following DataFrame:
```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie', 'David'],
    'age': [25, 30, 35, 28],
    'score': [85, 90, 88, 92]
})
```
- Select only the 'name' and 'age' columns
- Filter rows where age > 28
- Add a new column 'grade' based on score (>90: 'A', >85: 'B', else: 'C')

**Solution:**
```python
# Select columns
df[['name', 'age']]

# Filter rows
df[df['age'] > 28]

# Add grade column
df['grade'] = df['score'].apply(lambda x: 'A' if x > 90 else ('B' if x > 85 else 'C'))
```

### Intermediate Level

**Question 3: Data Cleaning**
Given a DataFrame with missing values:
```python
df = pd.DataFrame({
    'A': [1, 2, None, 4, 5],
    'B': [None, 2, 3, 4, None],
    'C': [1, 2, 3, 4, 5]
})
```
- Count missing values in each column
- Fill missing values in column 'A' with the mean
- Fill missing values in column 'B' with 0
- Drop any rows that still have missing values

**Solution:**
```python
# Count missing values
df.isna().sum()

# Fill with mean
df['A'].fillna(df['A'].mean(), inplace=True)

# Fill with 0
df['B'].fillna(0, inplace=True)

# Drop remaining missing values
df.dropna(inplace=True)
```

**Question 4: Grouping and Aggregation**
Given a sales DataFrame:
```python
df = pd.DataFrame({
    'product': ['A', 'B', 'A', 'B', 'A', 'B'],
    'sales': [100, 150, 120, 180, 110, 160],
    'region': ['North', 'North', 'South', 'South', 'North', 'South']
})
```
- Calculate total sales by product
- Calculate average sales by region
- Create a pivot table showing sales by product and region

**Solution:**
```python
# Total sales by product
df.groupby('product')['sales'].sum()

# Average sales by region
df.groupby('region')['sales'].mean()

# Pivot table
df.pivot_table(values='sales', index='product', columns='region', aggfunc='sum')
```

### Advanced Level

**Question 5: Complex Data Manipulation**
Given a gene expression DataFrame:
```python
df = pd.DataFrame({
    'gene': ['GENE1', 'GENE2', 'GENE3', 'GENE1', 'GENE2', 'GENE3'],
    'sample': ['S1', 'S1', 'S1', 'S2', 'S2', 'S2'],
    'expression': [10.5, 8.2, 12.1, 11.3, 9.5, 13.2],
    'condition': ['control', 'control', 'control', 'treatment', 'treatment', 'treatment']
})
```
- Calculate fold change (treatment/control) for each gene
- Find genes with fold change > 1.1
- Create a visualization showing expression levels by condition

**Solution:**
```python
# Calculate fold change
pivot_df = df.pivot_table(values='expression', index='gene', columns='condition', aggfunc='mean')
pivot_df['fold_change'] = pivot_df['treatment'] / pivot_df['control']

# Find genes with fold change > 1.1
significant_genes = pivot_df[pivot_df['fold_change'] > 1.1]

# Visualization
import matplotlib.pyplot as plt
df_pivot = df.pivot_table(values='expression', index='gene', columns='condition', aggfunc='mean')
df_pivot.plot(kind='bar', figsize=(10, 6))
plt.title('Gene Expression by Condition')
plt.ylabel('Expression Level')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

**Question 6: Time Series Analysis**
Given a time series DataFrame:
```python
dates = pd.date_range('2024-01-01', periods=100, freq='D')
df = pd.DataFrame({
    'date': dates,
    'value': np.random.randn(100).cumsum()
})
```
- Set 'date' as index
- Calculate 7-day rolling mean
- Plot the original data and rolling mean together

**Solution:**
```python
# Set date as index
df.set_index('date', inplace=True)

# Calculate rolling mean
df['rolling_mean'] = df['value'].rolling(window=7).mean()

# Plot
df[['value', 'rolling_mean']].plot(figsize=(12, 6))
plt.title('Time Series with 7-day Rolling Mean')
plt.ylabel('Value')
plt.show()
```

## Best Practices

1. **Keep Series homogeneous**: Maintain the same data type within a Series for optimal performance. Mixed types force `object` dtype, which is slower and uses more memory.
2. **Keep index unique when possible**: While Series allows duplicate indices, unique indices are recommended for most operations. Duplicate indices can cause unexpected behavior in indexing, alignment, and certain operations.
3. **Use vectorized operations**: Avoid loops when possible; Pandas operations are optimized
4. **Be mindful of memory**: For large datasets, use `dtype` parameter to specify data types
5. **Use `inplace=True` carefully**: It modifies the original DataFrame; consider creating copies
6. **Index appropriately**: Set meaningful indexes for faster lookups
7. **Handle missing data early**: Decide on strategy (drop, fill, interpolate) based on your data
8. **Use `.copy()` when needed**: Prevents SettingWithCopyWarning

## Common Pitfalls and Solutions

**Pitfall 1: SettingWithCopyWarning**
```python
# Bad
df[df['age'] > 30]['salary'] = 50000  # Warning!

# Good
df.loc[df['age'] > 30, 'salary'] = 50000
# Or
df_copy = df[df['age'] > 30].copy()
df_copy['salary'] = 50000
```

**Pitfall 2: Chained Indexing**
```python
# Bad
df['column1']['row1']  # May not work as expected

# Good
df.loc['row1', 'column1']
# Or
df.at['row1', 'column1']  # Faster for single value
```

**Pitfall 3: Duplicate indices causing unexpected behavior**
```python
# Series with duplicate indices
s = pd.Series([10, 20, 30], index=['a', 'b', 'a'])

# Accessing duplicate index returns Series, not single value
print(s['a'])  # Returns Series with both values, not a single value!

# Some operations may fail or behave unexpectedly
# Solution: Check for duplicates and handle them
if not s.index.is_unique:
    s = s[~s.index.duplicated(keep='first')]  # Keep first occurrence
    # Or
    s = s.groupby(s.index).first()  # Aggregate duplicates
```

**Pitfall 4: Not specifying data types**
```python
# Good practice for large datasets
df = pd.read_csv('large_file.csv', dtype={'id': 'int32', 'value': 'float32'})
```

#### Data Binning: cut() and qcut()

Binning continuous data into discrete categories is useful for analysis and visualization.

**For R users**: Pandas binning functions are similar to R's `cut()` and `quantile()` functions.

**R equivalent**:
```r
# R binning functions
cut(df$age, breaks=c(0, 30, 40, 50, 100), 
    labels=c('Young', 'Middle', 'Senior', 'Elderly'))  # Equal-width bins
cut(df$age, breaks=5)  # 5 equal-width bins
quantile(df$salary, probs=c(0, 0.25, 0.5, 0.75, 1.0))  # Quantiles
Hmisc::cut2(df$salary, g=4)  # Equal-size groups (similar to qcut)
```

**Pandas equivalent**:
```python
# Pandas binning functions
pd.cut(df['age'], bins=[0, 30, 40, 50, 100],
       labels=['Young', 'Middle', 'Senior', 'Elderly'])  # Equal-width bins
pd.cut(df['age'], bins=5)  # 5 equal-width bins
pd.qcut(df['salary'], q=4, labels=['Q1', 'Q2', 'Q3', 'Q4'])  # Equal-size groups
pd.qcut(df['salary'], q=[0, 0.25, 0.5, 0.75, 1.0])  # Custom quantiles
```

**cut() - Bin values into equal-width intervals**:

```python
# Create age groups
ages = [20, 25, 30, 35, 40, 45, 50, 55, 60]
df['age_group'] = pd.cut(df['age'], bins=[0, 30, 40, 50, 100], 
                         labels=['Young', 'Middle', 'Senior', 'Elderly'])

# Specify number of bins
df['age_group'] = pd.cut(df['age'], bins=5)  # 5 equal-width bins

# Custom bin edges
df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 100],
                         labels=['<25', '25-35', '35-45', '45+'])

# Include right edge
df['age_group'] = pd.cut(df['age'], bins=[0, 30, 50, 100], right=False)

# Return interval index
df['age_group'] = pd.cut(df['age'], bins=5, retbins=True)[0]
```

**qcut() - Bin values into equal-size groups (quantiles)**:

```python
# Create quartiles
df['salary_quartile'] = pd.qcut(df['salary'], q=4, labels=['Q1', 'Q2', 'Q3', 'Q4'])

# Specify quantiles
df['salary_group'] = pd.qcut(df['salary'], q=[0, 0.25, 0.5, 0.75, 1.0],
                            labels=['Low', 'Medium', 'High', 'Very High'])

# Equal-sized bins
df['group'] = pd.qcut(df['value'], q=10)  # Deciles

# Handle duplicates
df['group'] = pd.qcut(df['value'], q=5, duplicates='drop')
```

**Practical examples**:

```python
# Age categories
df['age_category'] = pd.cut(df['age'], 
                             bins=[0, 18, 35, 50, 65, 100],
                             labels=['Child', 'Young Adult', 'Adult', 'Middle Age', 'Senior'])

# Income brackets
df['income_bracket'] = pd.cut(df['income'],
                              bins=[0, 30000, 60000, 100000, float('inf')],
                              labels=['Low', 'Medium', 'High', 'Very High'])

# Performance quartiles
df['performance'] = pd.qcut(df['score'], q=4, 
                           labels=['Poor', 'Fair', 'Good', 'Excellent'])

# Custom binning with precision
df['binned'] = pd.cut(df['value'], bins=10, precision=2)
```

#### Cross-tabulation: crosstab()

`crosstab()` creates frequency tables (contingency tables) between two or more factors.

**For R users**: Pandas `crosstab()` is very similar to R's `table()` and `xtabs()` functions.

**R equivalent**:
```r
# R cross-tabulation
table(df$category, df$status)  # Simple two-way table
xtabs(~ category + status, data=df)  # Formula syntax
prop.table(table(df$category, df$status))  # Proportions
addmargins(table(df$category, df$status))  # Add margins (totals)
```

**Pandas equivalent**:
```python
# Pandas cross-tabulation
pd.crosstab(df['category'], df['status'])  # Simple two-way table
pd.crosstab(df['category'], df['status'], margins=True)  # Add margins
pd.crosstab(df['category'], df['status'], normalize=True)  # Proportions
pd.crosstab(df['category'], df['status'], normalize='index')  # Row percentages
```

**Basic crosstab**:

```python
# Simple two-way table
pd.crosstab(df['category'], df['status'])

# With margins (totals)
pd.crosstab(df['category'], df['status'], margins=True)

# Normalize (percentages)
pd.crosstab(df['category'], df['status'], normalize=True)  # Overall percentages
pd.crosstab(df['category'], df['status'], normalize='index')  # Row percentages
pd.crosstab(df['category'], df['status'], normalize='columns')  # Column percentages
```

**Advanced crosstab**:

```python
# Multiple variables
pd.crosstab([df['category'], df['region']], df['status'])

# With aggregation
pd.crosstab(df['category'], df['status'], values=df['sales'], aggfunc='mean')

# Multiple aggregations
pd.crosstab(df['category'], df['status'], 
           values=df['sales'], 
           aggfunc=['mean', 'sum', 'count'])

# Drop missing values
pd.crosstab(df['category'], df['status'], dropna=True)
```

**Practical examples**:

```python
# Survey response analysis
pd.crosstab(df['age_group'], df['satisfaction'], margins=True)

# Sales by region and product
pd.crosstab([df['region'], df['product']], df['status'], 
           values=df['sales'], aggfunc='sum')

# Conversion rates
conversion = pd.crosstab(df['source'], df['converted'], normalize='index')
print(conversion[True])  # Conversion rates by source

# Chi-square test (with scipy)
from scipy.stats import chi2_contingency
table = pd.crosstab(df['category'], df['status'])
chi2, p_value, dof, expected = chi2_contingency(table)
```

## Additional Important Concepts (Not Covered in Detail)

This guide now comprehensively covers:
- ✅ **String Operations** - Complete `.str` accessor with regex
- ✅ **DateTime Operations** - Full datetime functionality including resampling
- ✅ **Function Application** - Detailed `apply()`, `map()`, and `applymap()` with examples
- ✅ **Window Functions** - `rolling()`, `expanding()`, and `ewm()` with practical examples
- ✅ **Data Reshaping** - `melt()`, `stack()`, and `unstack()` with use cases
- ✅ **Data Binning** - `cut()` and `qcut()` with examples
- ✅ **Cross-tabulation** - `crosstab()` with normalization and aggregation

Here are additional advanced concepts you should explore:

### Advanced Indexing
- **MultiIndex (Hierarchical Indexing)**: Working with multiple index levels
  ```python
  df.set_index(['level1', 'level2'])  # Create hierarchical index
  df.loc[('A', 'x')]  # Access with multiple levels
  df.xs('A', level='level1')  # Cross-section
  df.swaplevel()  # Swap index levels
  ```
- **Reindexing**: Aligning data to a new index
  ```python
  df.reindex(new_index)  # Reorder/align to new index
  df.reindex_like(other_df)  # Match another DataFrame's index
  df.reindex(columns=new_columns)  # Reindex columns
  ```

### Categorical Data
- **Categorical dtype**: Memory-efficient for repeated strings
  ```python
  df['category'] = df['category'].astype('category')
  df['category'].cat.categories  # View categories
  df['category'].cat.codes  # View category codes
  df['category'].cat.reorder_categories(['A', 'B', 'C'])  # Reorder
  df['category'].cat.add_categories(['D'])  # Add categories
  ```

### Method Chaining
- **Chaining operations**: `df.query().groupby().agg()`
  ```python
  (df.query('age > 30')
     .groupby('city')
     .agg({'salary': 'mean', 'age': 'count'})
     .sort_values('salary', ascending=False))
  ```
- Improves code readability and efficiency

### Performance Optimization
- **Vectorization**: Using built-in operations instead of loops
- **Memory optimization**: Using appropriate dtypes
- **eval() and query()**: Fast expression evaluation for large DataFrames

### File I/O (Advanced)
- **Reading options**: `chunksize`, `usecols`, `nrows` for large files
- **Writing formats**: JSON, Parquet, HDF5, SQL databases
- **Compression**: Reading/writing compressed files

### Missing Data (Advanced)
- **Interpolation**: `interpolate()` for time series
- **Forward/backward fill**: `ffill()`, `bfill()`
- **Drop strategies**: `dropna()` with different parameters

These concepts become important as you work with more complex datasets and need advanced data manipulation techniques.

## Additional Resources

- **Official Documentation**: https://pandas.pydata.org/docs/
- **10 Minutes to Pandas**: https://pandas.pydata.org/docs/user_guide/10min.html
- **Pandas Cookbook**: Practical recipes for common tasks
- **Practice Datasets**: Kaggle, UCI Machine Learning Repository

## Key Takeaways for R Users

**Most Important Differences to Remember**:

1. **Indexing**: 
   - Pandas uses **0-based indexing** (like Python), R uses **1-based indexing**
   - Pandas has **label-based alignment** (operations align by index names, not positions)
   - Use `.loc` for label-based access, `.iloc` for position-based access

2. **Index is Always Present**:
   - Every Series/DataFrame has an index (even if just 0,1,2,...)
   - Index is integral to operations, not just metadata like R's row names

3. **Operations Align by Index**:
   - When adding two Series, Pandas aligns by index labels, not positions
   - This is different from R where operations are typically position-based

4. **Syntax Differences**:
   - Pandas uses method chaining: `df.method()` vs R's `function(df)`
   - Boolean operations need parentheses: `(df['A'] > 5) & (df['B'] < 10)`
   - Column access: `df['col']` (like `df[["col"]]` in R) or `df.col` (like `df$col`)

5. **Common Equivalents**:
   - `dplyr::filter()` → `df[df['col'] > value]` or `df.query()`
   - `dplyr::select()` → `df[['col1', 'col2']]`
   - `dplyr::mutate()` → `df['new_col'] = expression`
   - `dplyr::group_by() %>% summarise()` → `df.groupby().agg()`
   - `tidyr::pivot_longer()` → `df.melt()`
   - `tidyr::pivot_wider()` → `df.pivot()` or `df.pivot_table()`
   - `merge()` → `pd.merge()`
   - `table()` → `pd.crosstab()`

## Conclusion

If you're coming from R, Pandas will feel familiar but with important differences. The key is understanding that:
- **Pandas prioritizes label-based operations** (index alignment)
- **R prioritizes position-based operations** (by default)
- **Both are powerful**, but the mental model is slightly different

Mastering Pandas as an R user means:
1. Understanding the index system (it's always there and matters!)
2. Getting comfortable with 0-based indexing
3. Learning when to use `.loc` vs `.iloc`
4. Appreciating automatic index alignment in operations

Practice regularly with real datasets to become proficient. The side-by-side comparisons in this guide should help you quickly translate your R knowledge to Pandas.

**Remember**:
- Start with basic operations and gradually move to advanced techniques
- Refer back to the R comparisons when stuck
- Practice with datasets relevant to your field
- Join communities (Stack Overflow, Reddit r/datascience, r/learnpython) for help

Happy data analyzing with Pandas!

