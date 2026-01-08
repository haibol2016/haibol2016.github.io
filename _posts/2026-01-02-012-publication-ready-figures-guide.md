---
layout: post
title: "A Comprehensive Guide to Creating Publication-Ready Scientific Figures"
date: 2026-01-02
categories: [data-visualization, scientific-communication, bioinformatics]
tags: [ggplot2, matplotlib, inkscape, drawio, biorender, figure-preparation, publication, visualization, r, python, scientific-figures]
author: Haibo Liu, PhD
toc: true
---

## Introduction

Creating publication-ready figures is a critical skill for scientific communication. Well-designed figures can effectively convey complex data and concepts, while poorly prepared figures can undermine even the strongest research findings. This comprehensive guide covers the tools, techniques, and best practices needed to create professional scientific figures suitable for publication in top-tier journals.

### Why Publication-Ready Figures Matter

- **First impression**: Figures are often the first thing reviewers and readers see
- **Clarity**: Well-designed figures communicate results more effectively than text alone
- **Professionalism**: High-quality figures reflect the quality of your research
- **Journal requirements**: Most journals have specific requirements for figure formats, resolution, and style
- **Reproducibility**: Properly prepared figures can be easily modified and reused

### Common Requirements

Most journals require figures to meet certain standards:

- **Resolution**: Minimum 300 DPI (dots per inch) for print, 72-150 DPI for web
- **Formats**: PDF, EPS, or TIFF for print; PNG or JPEG for web
- **Color**: CMYK for print, RGB for web; colorblind-friendly palettes recommended
- **Typography**: Clear, readable fonts (typically Arial, Helvetica, or Times) at minimum 8-10pt
- **Layout**: Proper spacing, alignment, and panel labeling (A, B, C, etc.)

### Overview of the Figure Creation Workflow

A typical workflow for creating publication figures involves:

1. **Data visualization**: Generate plots using R or Python
2. **Initial export**: Save plots at high resolution
3. **Assembly**: Combine multiple plots into panels using vector graphics software
4. **Annotation**: Add labels, arrows, and other annotations
5. **Final export**: Export in the format required by your target journal

#### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│           Publication Figure Creation Workflow               │
└─────────────────────────────────────────────────────────────┘

STEP 1: Data Analysis & Visualization
   │
   ├─→ R (ggplot2) or Python (matplotlib/seaborn)
   │   Generate individual plots
   │   Export as PDF/SVG (vector) or PNG/TIFF (300+ DPI)
   │
   ▼
STEP 2: Initial Export
   │
   ├─→ High-resolution files (300+ DPI)
   ├─→ Vector formats preferred (PDF, SVG)
   ├─→ Keep source scripts (R/Python)
   │
   ▼
STEP 3: Figure Assembly
   │
   ├─→ Import into Inkscape/Illustrator
   ├─→ Arrange panels with proper spacing
   ├─→ Align panels consistently
   │
   ▼
STEP 4: Annotation & Labeling
   │
   ├─→ Add panel labels (A, B, C, D)
   ├─→ Add text annotations
   ├─→ Add arrows and highlights
   ├─→ Add legends if needed
   │
   ▼
STEP 5: Final Export
   │
   ├─→ Export in journal-required format
   ├─→ Verify resolution (300+ DPI)
   ├─→ Check file size
   └─→ Test quality at actual size

Optional Steps:
   • Create diagrams in draw.io/BioRender
   • Process images in ImageJ/Fiji
   • Combine with schematics
```

---

## Section 1: Overview of Tools and When to Use Them

Choosing the right tool for each task is crucial for efficient figure creation. Different tools excel at different aspects of figure preparation.

### Tool Comparison Table

| Tool | Best For | Strengths | Limitations | Cost |
|------|----------|-----------|-------------|------|
| **R (ggplot2)** | Statistical plots, data visualization | Powerful, reproducible, extensive customization | Steeper learning curve | Free |
| **Python (matplotlib/seaborn)** | Data visualization, statistical plots | Flexible, integrates with data analysis | Can be verbose for complex plots | Free |
| **Inkscape** | Vector graphics editing, figure assembly | Free, powerful, SVG-based | Less intuitive than Illustrator | Free |
| **draw.io** | Diagrams, flowcharts, schematics | Easy to use, web-based, templates | Limited for complex graphics | Free |
| **BioRender** | Biological illustrations, cell diagrams | Professional templates, biology-specific | Subscription required, limited customization | Paid |
| **Adobe Illustrator** | Professional vector graphics | Industry standard, powerful | Expensive, proprietary | Paid |
| **PowerPoint/Keynote** | Quick assembly, simple figures | Familiar interface, quick | Limited precision, not ideal for complex figures | Paid/Free |

### Decision Tree for Choosing Tools

```
                    Need to Create a Figure?
                            │
                            ▼
                    ┌───────────────┐
                    │ What type?    │
                    └───────┬───────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
   Data Plot          Diagram/Schematic    Image Processing
        │                   │                   │
        ├─→ R (ggplot2)     ├─→ draw.io         ├─→ ImageJ/Fiji
        │   or              │   (flowcharts)    │   (scientific)
        └─→ Python          ├─→ BioRender        └─→ GIMP
            (matplotlib)    │   (biology)            (general)
                            └─→ Inkscape
                                (custom)
                                
        │                   │
        ▼                   ▼
   Export high-res    Export vector
   (PDF/SVG/PNG)      (PDF/SVG)
        │                   │
        └───────────┬───────┘
                    │
                    ▼
            Need Assembly?
                    │
        ┌───────────┼───────────┐
        │                       │
        ▼                       ▼
    Inkscape              Illustrator
    (free)                (paid, advanced)
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
            Final Export
            (PDF/TIFF/PNG)
```

**For data plots:**
- Use **R (ggplot2)** if you're already using R for analysis
- Use **Python (matplotlib/seaborn)** if you're using Python for analysis
- Both can produce publication-quality plots

**For figure assembly and editing:**
- Use **Inkscape** for free, powerful vector editing
- Use **Adobe Illustrator** if you have access and need advanced features
- Use **PowerPoint/Keynote** for quick, simple assemblies (not recommended for complex figures)

**For diagrams and schematics:**
- Use **draw.io** for flowcharts, workflows, and simple diagrams
- Use **BioRender** for biological illustrations and cell diagrams
- Use **Inkscape/Illustrator** for custom, complex diagrams

**For image processing:**
- Use **ImageJ/Fiji** for scientific image analysis and processing
- Use **GIMP** for general raster image editing

### R vs Python for Data Visualization

**Choose R (ggplot2) if:**
- You're already using R for statistical analysis
- You need highly customizable, publication-quality plots
- You want a grammar-of-graphics approach
- You need integration with Bioconductor packages

**Choose Python (matplotlib/seaborn) if:**
- You're using Python for data analysis
- You need interactive plots (plotly, bokeh)
- You're working in a Python-based workflow
- You need integration with machine learning libraries

Both can produce excellent publication-quality figures. The choice often depends on your existing workflow and preferences.

---

## Section 2: Creating Plots with R

R, particularly with the ggplot2 package, is one of the most powerful tools for creating publication-quality scientific plots.

### ggplot2 Fundamentals

ggplot2 is based on the "grammar of graphics" philosophy, which allows you to build plots layer by layer.

#### Basic Syntax and Grammar of Graphics

```r
library(ggplot2)

# Basic structure
ggplot(data = your_data, aes(x = x_variable, y = y_variable)) +
  geom_point() +
  theme_minimal() +
  labs(x = "X Label", y = "Y Label", title = "Plot Title")
```

**Key components:**
- `ggplot()`: Creates the base plot and defines data and aesthetics
- `aes()`: Maps variables to visual properties (x, y, color, shape, etc.)
- `geom_*()`: Adds geometric layers (points, lines, bars, etc.)
- `theme_*()`: Controls appearance (themes, fonts, colors)
- `labs()`: Adds labels and titles

#### Common Plot Types

**Scatter plot:**
```r
ggplot(data, aes(x = x_var, y = y_var)) +
  geom_point(size = 2, alpha = 0.6) +
  theme_minimal()
```

**Line plot:**
```r
ggplot(data, aes(x = x_var, y = y_var, color = group)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal()
```

**Bar plot:**
```r
ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal()
```

**Box plot:**
```r
ggplot(data, aes(x = group, y = value, fill = group)) +
  geom_boxplot() +
  theme_minimal()
```

**Heatmap:**
```r
library(pheatmap)
pheatmap(data_matrix, 
         color = colorRampPalette(c("blue", "white", "red"))(100),
         cluster_rows = TRUE,
         cluster_cols = TRUE)
```

#### Themes and Customization

```r
# Built-in themes
theme_minimal()    # Clean, minimal
theme_classic()     # Classic, no grid
theme_bw()          # Black and white
theme_dark()        # Dark background

# Custom theme
theme_custom <- theme_minimal() +
  theme(
    text = element_text(size = 12, family = "Arial"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.position = "right"
  )
```

#### Exporting High-Resolution Figures

```r
# PDF (vector format, best for publication)
ggsave("figure.pdf", width = 7, height = 5, units = "in", dpi = 300)

# PNG (raster format, high resolution)
ggsave("figure.png", width = 7, height = 5, units = "in", dpi = 300)

# TIFF (raster format, for journals requiring TIFF)
ggsave("figure.tiff", width = 7, height = 5, units = "in", 
       dpi = 300, compression = "lzw")

# SVG (vector format, editable)
ggsave("figure.svg", width = 7, height = 5, units = "in")
```

### Advanced ggplot2

#### Multi-Panel Figures

**Using facet_wrap:**
```r
ggplot(data, aes(x = x_var, y = y_var)) +
  geom_point() +
  facet_wrap(~ group, ncol = 2) +
  theme_minimal()
```

**Using facet_grid:**
```r
ggplot(data, aes(x = x_var, y = y_var)) +
  geom_point() +
  facet_grid(condition ~ treatment) +
  theme_minimal()
```

#### Combining Plots

**Using cowplot:**
```r
library(cowplot)

# Create individual plots
p1 <- ggplot(data1, aes(x, y)) + geom_point()
p2 <- ggplot(data2, aes(x, y)) + geom_point()
p3 <- ggplot(data3, aes(x, y)) + geom_point()
p4 <- ggplot(data4, aes(x, y)) + geom_point()

# Combine into grid
combined <- plot_grid(p1, p2, p3, p4, 
                     labels = c("A", "B", "C", "D"),
                     ncol = 2, nrow = 2)

# Save combined plot
ggsave("combined_figure.pdf", combined, width = 10, height = 10, dpi = 300)
```

**Using patchwork:**
```r
library(patchwork)

p1 + p2 + p3 + p4 + 
  plot_layout(ncol = 2) +
  plot_annotation(tag_levels = "A")
```

#### Custom Annotations

```r
ggplot(data, aes(x = x_var, y = y_var)) +
  geom_point() +
  annotate("text", x = 5, y = 10, label = "Important point", 
           size = 4, fontface = "bold") +
  annotate("rect", xmin = 2, xmax = 4, ymin = 8, ymax = 12,
           alpha = 0.2, fill = "blue") +
  annotate("segment", x = 1, xend = 3, y = 5, yend = 7,
           arrow = arrow(), color = "red", size = 1)
```

#### Color Palettes

**Viridis (colorblind-friendly):**
```r
library(viridis)

ggplot(data, aes(x = x, y = y, color = value)) +
  geom_point() +
  scale_color_viridis_c()  # Continuous
  # or
  scale_color_viridis_d()  # Discrete
```

**ColorBrewer:**
```r
ggplot(data, aes(x = x, y = y, fill = group)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set2")  # Qualitative
  # or
  scale_fill_brewer(palette = "RdYlBu")  # Diverging
```

**Custom colors:**
```r
# Define custom palette
custom_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                   "#0072B2", "#D55E00", "#CC79A7")

ggplot(data, aes(x = x, y = y, color = group)) +
  geom_point() +
  scale_color_manual(values = custom_colors)
```

**Example: Creating a color palette comparison figure**

```r
# Compare colorblind-friendly vs problematic palettes
library(ggplot2)
library(viridis)
library(patchwork)

# Create sample data
set.seed(123)
data <- data.frame(
  x = rep(1:5, 3),
  y = rnorm(15),
  group = rep(c("A", "B", "C"), each = 5)
)

# Good: Colorblind-friendly (viridis)
p1 <- ggplot(data, aes(x = x, y = y, color = group)) +
  geom_point(size = 3) +
  scale_color_viridis_d() +
  labs(title = "Colorblind-Friendly (Viridis)", 
       subtitle = "Distinguishable by colorblind viewers") +
  theme_minimal()

# Bad: Red-green palette (problematic)
p2 <- ggplot(data, aes(x = x, y = y, color = group)) +
  geom_point(size = 3) +
  scale_color_manual(values = c("red", "green", "blue")) +
  labs(title = "Problematic (Red-Green)", 
       subtitle = "Hard to distinguish for colorblind viewers") +
  theme_minimal()

# Combine
p1 + p2
ggsave("color_palette_comparison.pdf", width = 10, height = 4, dpi = 300)
```

### Base R Plotting

While ggplot2 is generally preferred, base R plotting can be useful for quick plots or when you need specific base R functionality.

**When to use base R:**
- Quick exploratory plots
- When working with base R graphics objects
- When you need specific base R plot types

**Export functions:**
```r
# PDF
pdf("figure.pdf", width = 7, height = 5)
plot(x, y)
dev.off()

# PNG
png("figure.png", width = 7, height = 5, units = "in", res = 300)
plot(x, y)
dev.off()

# TIFF
tiff("figure.tiff", width = 7, height = 5, units = "in", res = 300)
plot(x, y)
dev.off()
```

### Other Useful R Packages

**ComplexHeatmap for advanced heatmaps:**
```r
library(ComplexHeatmap)
library(circlize)

# Create heatmap
Heatmap(data_matrix,
        name = "Expression",
        col = colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        show_row_names = FALSE)

# Save
pdf("heatmap.pdf", width = 8, height = 6)
draw(Heatmap(...))
dev.off()
```

**pheatmap for simple heatmaps:**
```r
library(pheatmap)

pheatmap(data_matrix,
         color = colorRampPalette(c("blue", "white", "red"))(100),
         cluster_rows = TRUE,
         cluster_cols = TRUE)
```

**VennDiagram for Venn diagrams:**
```r
library(VennDiagram)

venn.diagram(list(Set1 = set1, Set2 = set2, Set3 = set3),
             filename = "venn_diagram.tiff",
             imagetype = "tiff",
             resolution = 300)
```

**circlize for circular plots:**
```r
library(circlize)

circos.initialize(factors = factors, x = x_values)
circos.trackPlotRegion(factors = factors, y = y_values,
                       panel.fun = function(x, y) {
                         circos.points(x, y, col = "red", pch = 16)
                       })
```

---

## Section 3: Creating Plots with Python

Python offers powerful plotting libraries, with matplotlib and seaborn being the most popular for scientific visualization.

### matplotlib Fundamentals

matplotlib is the foundation for most Python plotting and provides fine-grained control over every aspect of a plot.

#### Basic Plotting Syntax

```python
import matplotlib.pyplot as plt
import numpy as np

# Basic plot
plt.figure(figsize=(7, 5))
plt.plot(x, y, 'o-', label='Data')
plt.xlabel('X Label')
plt.ylabel('Y Label')
plt.title('Plot Title')
plt.legend()
plt.tight_layout()
plt.savefig('figure.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

#### Figure and Axes Objects

**Object-oriented approach (recommended):**
```python
fig, ax = plt.subplots(figsize=(7, 5))
ax.plot(x, y, 'o-', label='Data')
ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_title('Plot Title')
ax.legend()
fig.tight_layout()
fig.savefig('figure.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

**Multiple subplots:**
```python
fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(10, 10))
axes[0, 0].plot(x1, y1)
axes[0, 1].plot(x2, y2)
axes[1, 0].plot(x3, y3)
axes[1, 1].plot(x4, y4)
fig.tight_layout()
fig.savefig('multi_panel.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

#### Export Settings

```python
# PDF (vector format)
fig.savefig('figure.pdf', dpi=300, bbox_inches='tight')

# PNG (raster format, high resolution)
fig.savefig('figure.png', dpi=300, bbox_inches='tight')

# TIFF (for journals)
fig.savefig('figure.tiff', dpi=300, bbox_inches='tight', format='tiff')

# SVG (vector format, editable)
fig.savefig('figure.svg', bbox_inches='tight')
```

### seaborn

seaborn provides high-level statistical visualizations built on matplotlib.

#### Statistical Visualizations

```python
import seaborn as sns

# Set style
sns.set_style("whitegrid")
sns.set_palette("husl")

# Scatter plot with regression
sns.lmplot(x='x_var', y='y_var', data=data, hue='group')

# Box plot
sns.boxplot(x='group', y='value', data=data)

# Violin plot
sns.violinplot(x='group', y='value', data=data)

# Heatmap
sns.heatmap(data_matrix, annot=True, cmap='viridis')

# Save
plt.savefig('figure.pdf', dpi=300, bbox_inches='tight')
```

#### Built-in Themes

```python
# Available themes
sns.set_style("darkgrid")    # Dark background with grid
sns.set_style("whitegrid")    # White background with grid
sns.set_style("dark")         # Dark background, no grid
sns.set_style("white")        # White background, no grid
sns.set_style("ticks")        # Minimal, with ticks

# Context settings (affect scale)
sns.set_context("paper")       # Smallest
sns.set_context("notebook")    # Default
sns.set_context("talk")        # Larger
sns.set_context("poster")       # Largest
```

#### Integration with matplotlib

```python
fig, ax = plt.subplots(figsize=(7, 5))
sns.scatterplot(x='x_var', y='y_var', data=data, ax=ax)
ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
fig.savefig('figure.pdf', dpi=300, bbox_inches='tight')
```

### plotly

plotly creates interactive plots that can be exported as static images.

```python
import plotly.graph_objects as go
import plotly.express as px

# Interactive scatter plot
fig = px.scatter(data, x='x_var', y='y_var', color='group')
fig.show()

# Export as static image
fig.write_image("figure.pdf", width=700, height=500, scale=3)
# or
fig.write_image("figure.png", width=700, height=500, scale=3)
```

### Other Python Libraries

**pandas plotting:**
```python
import pandas as pd

df.plot(x='x_var', y='y_var', kind='scatter')
plt.savefig('figure.pdf', dpi=300, bbox_inches='tight')
```

**bokeh (interactive):**
```python
from bokeh.plotting import figure, output_file, save

p = figure(width=700, height=500)
p.circle(x, y, size=10, color="navy", alpha=0.5)
output_file("figure.html")
save(p)
```

**altair (declarative):**
```python
import altair as alt

chart = alt.Chart(data).mark_point().encode(
    x='x_var',
    y='y_var',
    color='group'
)
chart.save('figure.png', scale_factor=3)
```

### Exporting from Python

**High-resolution export:**
```python
# Always specify DPI for raster formats
fig.savefig('figure.png', dpi=300, bbox_inches='tight')

# For vector formats, DPI doesn't matter
fig.savefig('figure.pdf', bbox_inches='tight')
fig.savefig('figure.svg', bbox_inches='tight')
```

**Vector formats:**
```python
# PDF (best for publication)
fig.savefig('figure.pdf', bbox_inches='tight')

# SVG (editable in Inkscape/Illustrator)
fig.savefig('figure.svg', bbox_inches='tight')

# EPS (some journals require)
fig.savefig('figure.eps', bbox_inches='tight')
```

---

## Section 4: Vector Graphics Editing with Inkscape

Inkscape is a free, open-source vector graphics editor that's excellent for assembling and editing publication figures.

### Introduction to Inkscape

#### Installation and Setup

- **Download**: Available from https://inkscape.org/
- **Platforms**: Windows, macOS, Linux
- **Cost**: Free and open-source

#### Interface Overview

Key components:
- **Toolbox**: Left sidebar with drawing and editing tools
- **Canvas**: Main working area
- **Command bar**: Top toolbar with common commands
- **Tool controls**: Context-sensitive controls for selected tools
- **Color palette**: Bottom of window
- **Layers panel**: Right sidebar (View → Layers)

### Common Tasks

#### Importing Plots from R/Python

1. **Export from R/Python as PDF or SVG**
   - PDF is preferred for most cases
   - SVG allows full editing of plot elements

2. **Import into Inkscape**
   - File → Import (or Ctrl+I)
   - Select your PDF/SVG file
   - Choose "Embed" or "Link" (embed is usually better)

3. **Ungroup if needed**
   - Select imported object
   - Object → Ungroup (or Ctrl+Shift+G)
   - May need to ungroup multiple times

#### Arranging Multiple Panels

1. **Import all panels** as separate files or objects
2. **Position panels** using:
   - Select tool (F1) to move objects
   - Align and Distribute panel (Object → Align and Distribute, or Shift+Ctrl+A)
3. **Use guides** for alignment:
   - Drag from rulers to create guides
   - View → Guides to show/hide
4. **Group panels** (Ctrl+G) if needed

#### Adding Annotations and Labels

1. **Text tool (F8)**
   - Click to add text
   - Use toolbar to adjust font, size, style
2. **Arrow tool**
   - Draw → Bezier tool (Shift+F6)
   - Draw line, then add arrowhead (Fill and Stroke → Stroke style)
3. **Shapes**
   - Rectangle (F4), Ellipse (F5), etc.
   - Use for highlighting regions

#### Adjusting Text and Fonts

1. **Select text** with text tool (F8)
2. **Font settings** in toolbar:
   - Font family
   - Font size
   - Bold, italic
3. **Text and Font dialog** (Text → Text and Font, or Shift+Ctrl+T):
   - More advanced text options
   - Character spacing, line height, etc.

#### Aligning and Distributing Objects

1. **Select multiple objects** (Shift+click or drag selection)
2. **Open Align and Distribute panel** (Shift+Ctrl+A)
3. **Align options**:
   - Align left/right/center (horizontal)
   - Align top/bottom/center (vertical)
4. **Distribute options**:
   - Distribute evenly with spacing
   - Distribute centers

### Advanced Techniques

#### Path Editing

1. **Node tool (F2)**
   - Select path, then use node tool
   - Click nodes to select, drag to move
   - Add/delete nodes as needed
2. **Path operations** (Path menu):
   - Union, Difference, Intersection
   - Simplify, Inset/Outset

#### Clipping and Masking

1. **Clipping**:
   - Create clipping path (shape)
   - Select object and clipping path
   - Object → Clip → Set
2. **Masking**:
   - Create mask (gradient or shape)
   - Select object and mask
   - Object → Mask → Set

#### Creating Custom Shapes

1. **Draw shapes** with Bezier tool (Shift+F6)
2. **Combine shapes** with path operations
3. **Edit nodes** with node tool (F2)
4. **Save as custom shape** if needed

#### Working with Layers

1. **Create layers** (Layer → Add Layer)
2. **Organize content** into layers
3. **Lock layers** to prevent accidental edits
4. **Hide/show layers** for easier editing

### Export Settings

#### PDF for Publication

1. **File → Save As**
2. **Select PDF format**
3. **Options**:
   - Resolution: 300 DPI (for rasterized content)
   - Text to Path: Convert text to paths (prevents font issues)
   - Embed fonts: Include fonts in PDF

#### PNG at High Resolution

1. **File → Export PNG Image** (Shift+Ctrl+E)
2. **Set resolution**: 300 DPI or higher
3. **Set page or selection**: Export entire page or selected area
4. **Click Export**

#### SVG for Web

1. **File → Save As**
2. **Select SVG format**
3. **Options**:
   - Plain SVG: Standard SVG
   - Optimized SVG: Smaller file size
   - Inkscape SVG: Preserves Inkscape-specific features

---

## Section 5: Creating Diagrams with draw.io

draw.io (now diagrams.net) is a free, web-based diagramming tool that's excellent for creating flowcharts, workflows, and scientific diagrams.

### Introduction to draw.io

#### Online vs Desktop Version

- **Online**: https://app.diagrams.net/ (no installation needed)
- **Desktop**: Available for Windows, macOS, Linux
- **Both are free** and have similar functionality

#### Interface Overview

Key features:
- **Shape library**: Left sidebar with shapes and templates
- **Canvas**: Main drawing area
- **Format panel**: Right sidebar for styling
- **Layers panel**: For organizing complex diagrams
- **Search**: Find shapes quickly

### Creating Scientific Diagrams

#### Flowcharts and Workflows

1. **Start with template** or blank canvas
2. **Add shapes** from shape library:
   - Process: Rectangles
   - Decision: Diamonds
   - Start/End: Rounded rectangles
3. **Connect shapes** with arrows:
   - Select shape, drag connector point
   - Connector tool for custom paths
4. **Add labels** to shapes and connectors
5. **Style consistently** using format panel

#### Network Diagrams

1. **Use network shapes** from shape library
2. **Add nodes** (devices, components, etc.)
3. **Connect nodes** with lines/arrows
4. **Label connections** and nodes
5. **Group related elements** if needed

#### Process Diagrams

1. **Use process templates** or create custom
2. **Show steps** in sequence
3. **Use arrows** to show flow
4. **Add annotations** for clarity
5. **Use color coding** for different process types

#### Custom Shapes and Templates

1. **Create custom shapes**:
   - Draw shape
   - Right-click → Edit Style
   - Save as custom shape
2. **Use templates**:
   - File → New from Template
   - Browse template library
3. **Save as template** for reuse

### Best Practices

#### Consistent Styling

1. **Define style** at the beginning:
   - Colors (use color palette)
   - Fonts (consistent across diagram)
   - Line styles and weights
2. **Apply style** consistently:
   - Use format panel
   - Copy style (Format → Copy Style, Ctrl+Shift+C)
   - Paste style (Format → Paste Style, Ctrl+Shift+V)

#### Alignment and Spacing

1. **Use alignment tools**:
   - Select multiple objects
   - Format → Align (left, right, center, etc.)
2. **Use distribute tools**:
   - Format → Distribute (even spacing)
3. **Use grid and snap**:
   - View → Grid
   - View → Snap to Grid

#### Color Schemes

1. **Use colorblind-friendly palettes**
2. **Limit color palette** (3-5 colors)
3. **Use color consistently** (same meaning = same color)
4. **Consider grayscale** for print

### Export Options

#### PDF, PNG, SVG Formats

1. **File → Export as**
2. **Select format**:
   - PDF: Vector format, best for publication
   - PNG: Raster format, specify resolution
   - SVG: Vector format, editable
3. **Set options**:
   - Border: Add margin around diagram
   - Selection only: Export selected area
   - Transparent background: For overlays

#### Resolution Settings

1. **For PNG export**:
   - Set zoom level (higher = better quality)
   - Or specify pixel dimensions
2. **For PDF/SVG**:
   - Vector format, resolution not applicable
   - Scale appropriately

---

## Section 6: Scientific Illustrations with BioRender

BioRender is a specialized tool for creating biological and scientific illustrations with professional templates.

### Introduction to BioRender

#### Account Setup

1. **Sign up** at https://www.biorender.com/
2. **Choose plan**:
   - Free: Limited icons and exports
   - Academic: Full access for academic use
   - Commercial: For commercial use
3. **Verify academic email** if using academic plan

#### Template Library

BioRender offers thousands of pre-made scientific icons:
- **Cells and organelles**
- **Molecules and proteins**
- **Equipment and instruments**
- **Animals and plants**
- **Pathways and processes**

### Creating Biological Illustrations

#### Cell Diagrams

1. **Start new illustration**
2. **Search icons** for cell components
3. **Drag and drop** icons onto canvas
4. **Arrange and connect** components
5. **Add labels** and annotations
6. **Style consistently**

#### Pathway Illustrations

1. **Use pathway templates** or create custom
2. **Add pathway components** (proteins, molecules, etc.)
3. **Connect components** with arrows/lines
4. **Add labels** and annotations
5. **Use color coding** for different pathway types

#### Experimental Schematics

1. **Create experimental flow** diagram
2. **Use equipment icons** (microscopes, pipettes, etc.)
3. **Show sample flow** through experiment
4. **Add time points** or conditions
5. **Annotate key steps**

### Customization

#### Adding Custom Elements

1. **Import images** if needed
2. **Create custom shapes** using drawing tools
3. **Combine icons** to create new elements
4. **Save custom icons** for reuse

#### Color Schemes

1. **Use BioRender color palette** or custom colors
2. **Apply colors consistently**
3. **Consider colorblind-friendly options**
4. **Use color to convey meaning**

#### Text and Labels

1. **Add text** using text tool
2. **Format text** (font, size, style)
3. **Add arrows** and annotations
4. **Use consistent labeling** style

### Export and Licensing

#### Export Formats

1. **PNG**: High resolution (up to 300 DPI)
2. **PDF**: Vector format
3. **SVG**: Editable vector format
4. **PowerPoint**: For presentations

#### License Considerations for Publication

1. **Check license** for your plan:
   - Free: Limited use, attribution required
   - Academic: Full use for academic publications
   - Commercial: Commercial use allowed
2. **Read terms** carefully
3. **Cite BioRender** if required by license
4. **Contact support** if unsure about usage rights

---

## Section 7: Other Useful Tools

Several other tools can be valuable for specific aspects of figure creation.

### Adobe Illustrator

**When to use:**
- Professional vector graphics editing
- Complex figure assembly
- Advanced typography and design
- Industry-standard workflows

**Key features:**
- Powerful vector editing tools
- Advanced typography controls
- Professional color management
- Extensive plugin ecosystem
- Industry standard (many journals expect Illustrator files)

**Limitations:**
- Expensive subscription
- Steeper learning curve
- Proprietary format

### PowerPoint/Keynote

**Quick figure assembly:**
- Familiar interface
- Easy to use
- Good for simple multi-panel figures
- Can export as PDF/PNG

**Limitations:**
- Limited precision
- Not ideal for complex graphics
- Lower quality exports
- Not recommended for publication-quality figures

**When to use:**
- Quick drafts
- Simple presentations
- When other tools aren't available
- Not for final publication figures

### ImageJ/Fiji

**Image processing and analysis:**
- Scientific image analysis
- Processing microscopy images
- Creating figure panels from images
- Measurement and quantification

**Creating figure panels:**
1. **Open images** in ImageJ
2. **Process images** (adjust contrast, scale, etc.)
3. **Create montage** (Image → Stacks → Make Montage)
4. **Export** as TIFF or PNG

**Best for:**
- Microscopy images
- Image analysis workflows
- Scientific image processing
- Not for data visualization

### GIMP

**Raster image editing:**
- Free alternative to Photoshop
- Image manipulation
- Photo editing
- Creating composite images

**When to use vs Inkscape:**
- **GIMP**: Raster images, photo editing, image manipulation
- **Inkscape**: Vector graphics, figure assembly, scalable graphics

**Use GIMP when:**
- Working with photographs
- Need advanced image manipulation
- Creating raster-based graphics
- Image processing tasks

**Use Inkscape when:**
- Working with vector graphics
- Assembling publication figures
- Need scalable graphics
- Combining plots and diagrams

---

## Section 8: Best Practices for Publication Figures

Following best practices ensures your figures meet journal requirements and communicate effectively.

### Resolution and Formats

#### DPI Requirements

- **Print publication**: Minimum 300 DPI
- **Web publication**: 72-150 DPI (often 300 DPI for high-quality web)
- **Posters**: 150-300 DPI depending on size
- **Presentations**: 150-200 DPI

**Check your DPI:**
- In R: `ggsave(..., dpi = 300)`
- In Python: `plt.savefig(..., dpi = 300)`
- In Inkscape: Export PNG at 300 DPI

#### Resolution Comparison Example

**Visual guide to resolution quality:**

```
Low Resolution (72 DPI)          High Resolution (300 DPI)
───────────────────────          ───────────────────────
[Pixelated, blurry]              [Sharp, clear]
Not suitable for print           Suitable for print
File size: Small                 File size: Larger
Use: Web only                    Use: Publication
```

**Example code to demonstrate resolution differences:**

```r
# Create a test plot
library(ggplot2)
data <- data.frame(x = 1:10, y = rnorm(10))

p <- ggplot(data, aes(x, y)) + 
  geom_point(size = 3) + 
  geom_line() +
  theme_minimal()

# Export at different resolutions
ggsave("figure_72dpi.png", p, width = 7, height = 5, dpi = 72)   # Too low
ggsave("figure_150dpi.png", p, width = 7, height = 5, dpi = 150)  # Acceptable for web
ggsave("figure_300dpi.png", p, width = 7, height = 5, dpi = 300) # Publication quality
ggsave("figure_600dpi.png", p, width = 7, height = 5, dpi = 600) # Very high quality
```

#### Vector vs Raster Formats

**Vector formats (PDF, EPS, SVG):**
- Scalable without quality loss
- Smaller file sizes for simple graphics
- Editable in vector graphics software
- Best for: Line plots, diagrams, schematics

**Raster formats (PNG, TIFF, JPEG):**
- Fixed resolution
- Larger file sizes at high resolution
- Best for: Photographs, complex images, heatmaps

**Recommendation**: Use vector formats when possible, raster at high resolution when necessary.

#### Format Comparison Diagram

```
Vector Formats (PDF, EPS, SVG)          Raster Formats (PNG, TIFF, JPEG)
─────────────────────────────────       ────────────────────────────────
✓ Scalable (zoom without loss)         ✗ Fixed resolution
✓ Smaller files (simple graphics)     ✓ Better for photos
✓ Editable elements                    ✗ Larger files (high res)
✓ Text remains editable                ✗ Text becomes pixels
Best for:                              Best for:
  • Line plots                           • Photographs
  • Diagrams                             • Complex images
  • Schematics                           • Heatmaps
  • Simple graphics                      • Microscopy images

When to use:
  ┌─────────────────┐
  │ Simple graphics │ → Vector (PDF/SVG)
  │ Complex images  │ → Raster (PNG/TIFF at 300+ DPI)
  │ Photos          │ → Raster (TIFF/PNG at 300+ DPI)
  │ Line plots      │ → Vector (PDF/SVG)
  └─────────────────┘
```

#### File Size Considerations

- **Journal limits**: Many journals have file size limits (often 10-20 MB)
- **Optimize images**: Compress when possible without losing quality
- **Use appropriate format**: Vector for simple graphics, high-res raster for complex images

### Color

#### Colorblind-Friendly Palettes

**Recommended palettes:**
- **Viridis**: Excellent for continuous data
- **ColorBrewer**: Many colorblind-friendly options
- **Okabe-Ito**: Specifically designed for colorblind accessibility

**Tools to check:**
- Color Oracle (simulates colorblindness)
- Coblis (online colorblind simulator)
- Test with grayscale conversion

**Avoid:**
- Red-green combinations (most common colorblindness)
- Relying solely on color to convey information
- Too many colors (3-5 is usually sufficient)

#### Color Palette Examples

**Example: Colorblind-friendly vs problematic palettes**

```r
# Create comparison figure
library(ggplot2)
library(viridis)
library(patchwork)

# Sample data
data <- data.frame(
  category = rep(LETTERS[1:5], 2),
  value = c(10, 15, 12, 18, 14, 8, 11, 9, 16, 13),
  group = rep(c("Control", "Treatment"), each = 5)
)

# Good: Colorblind-friendly palette
p1 <- ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_viridis_d() +
  labs(title = "Colorblind-Friendly (Viridis)",
       subtitle = "Distinguishable by all viewers") +
  theme_minimal()

# Bad: Red-green palette
p2 <- ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("red", "green")) +
  labs(title = "Problematic (Red-Green)",
       subtitle = "Hard to distinguish for colorblind viewers") +
  theme_minimal()

# Good: Using shapes + colors
p3 <- ggplot(data, aes(x = category, y = value, 
                       color = group, shape = group)) +
  geom_point(size = 4) +
  scale_color_viridis_d() +
  labs(title = "Best Practice (Color + Shape)",
       subtitle = "Accessible to all viewers") +
  theme_minimal()

# Combine
(p1 + p2) / p3
ggsave("color_accessibility_comparison.pdf", width = 10, height = 8, dpi = 300)
```

**Color palette reference:**

```
Colorblind-Friendly Palettes:

Viridis (Continuous):
  [Dark Blue] → [Green] → [Yellow]
  ✓ Works for all color vision types
  ✓ Perceptually uniform

ColorBrewer Set2 (Qualitative):
  [Light Blue] [Light Green] [Light Yellow] [Pink] [Light Purple]
  ✓ Colorblind-friendly
  ✓ Good for categorical data

Okabe-Ito (Qualitative):
  [Orange] [Sky Blue] [Bluish Green] [Yellow] [Blue] [Vermillion] [Reddish Purple]
  ✓ Specifically designed for colorblind accessibility
  ✓ 7 distinct colors

Problematic Combinations:
  ✗ Red + Green (most common colorblindness)
  ✗ Blue + Purple (some colorblind types)
  ✗ Too many similar colors
```

#### CMYK vs RGB

**CMYK (Cyan, Magenta, Yellow, Black):**
- Used for print
- Some journals require CMYK
- Smaller color gamut than RGB
- Convert from RGB if needed

**RGB (Red, Green, Blue):**
- Used for digital/screen
- Larger color gamut
- Default for most software
- Convert to CMYK for print if required

**When to use:**
- **RGB**: Digital publications, web, presentations
- **CMYK**: Print publications (check journal requirements)

#### Journal Color Requirements

- **Check journal guidelines** before finalizing figures
- **Some journals require**: Specific color modes, color spaces
- **Some journals prefer**: Grayscale for certain figure types
- **Always verify** requirements for your target journal

### Typography

#### Font Choices

**Recommended fonts:**
- **Arial**: Sans-serif, widely available, clear
- **Helvetica**: Similar to Arial, professional
- **Times New Roman**: Serif, traditional, readable
- **Avoid**: Decorative fonts, script fonts, very thin fonts

**Considerations:**
- **Sans-serif** (Arial, Helvetica): Modern, clean, good for labels
- **Serif** (Times): Traditional, good for body text in figures
- **Monospace** (Courier): For code, sequences, alignments

#### Font Sizes

- **Minimum**: 8-10pt for print
- **Recommended**: 10-12pt for labels
- **Titles**: 12-14pt
- **Small text**: Never below 8pt
- **Test readability**: Print at actual size to verify

#### Consistency Across Panels

- **Use same font** throughout figure
- **Use same font sizes** for similar elements
- **Consistent styling** for labels, titles, annotations
- **Create style guide** for your figures

### Layout

#### Panel Labeling

- **Use letters**: A, B, C, D for panels
- **Placement**: Top-left corner of each panel
- **Style**: Bold, sans-serif, consistent size
- **Spacing**: Adequate space from panel edge

#### Spacing and Margins

- **Between panels**: Adequate spacing (not too tight, not too loose)
- **Margins**: Leave space around figure edges
- **Alignment**: Align panels consistently
- **Use guides** in Inkscape/Illustrator for alignment

#### Aspect Ratios

- **Consider journal requirements**: Single column vs double column
- **Common sizes**:
  - Single column: 3.5 inches wide
  - Double column: 7 inches wide
  - Full page: 7-8 inches wide
- **Maintain aspect ratio** when resizing

### File Organization

#### Naming Conventions

**Good naming:**
- `Figure1_panelA_scatter.pdf`
- `Figure2_heatmap_final_v2.pdf`
- `Figure3_schematic_annotated.pdf`

**Include:**
- Figure number
- Panel identifier
- Content description
- Version number (if multiple versions)

#### Version Control

- **Keep source files**: R/Python scripts, Inkscape files
- **Track versions**: Use version numbers or dates
- **Document changes**: Note what changed in each version
- **Use Git** for code/scripts if possible

#### Source File Preservation

- **Keep original data**
- **Keep analysis scripts** (R/Python)
- **Keep vector graphics files** (Inkscape/Illustrator)
- **Document software versions**
- **Create README** explaining figure creation process

---

## Section 9: Journal-Specific Requirements

Different journals have specific requirements for figures. Always check your target journal's guidelines.

### Common Journal Requirements

#### Nature/Science

**Requirements:**
- **Resolution**: 300-600 DPI
- **Formats**: PDF, EPS, or TIFF
- **Color**: RGB or CMYK (specify)
- **Fonts**: Arial or Helvetica, minimum 6pt
- **Figure width**: Single column (89 mm) or double column (183 mm)
- **File size**: Maximum 10 MB per figure

**Tips:**
- Use high-quality, clear figures
- Ensure all text is readable
- Follow style guide precisely

#### Cell Press

**Requirements:**
- **Resolution**: 300 DPI minimum
- **Formats**: PDF, EPS, or TIFF
- **Color**: RGB preferred
- **Fonts**: Arial or Helvetica, 8-12pt
- **Figure width**: Single (85 mm) or double (174 mm) column

**Tips:**
- Consistent styling across all figures
- Clear, professional appearance
- Follow Cell Press figure guidelines

#### PLoS

**Requirements:**
- **Resolution**: 300 DPI minimum
- **Formats**: PDF, EPS, TIFF, or PNG
- **Color**: RGB
- **Fonts**: Arial, Helvetica, or Times, minimum 8pt
- **Figure width**: Single (3.5 inches) or double (7 inches) column

**Tips:**
- Colorblind-friendly palettes recommended
- Clear, accessible figures
- Follow PLoS figure guidelines

#### eLife

**Requirements:**
- **Resolution**: 300 DPI minimum
- **Formats**: PDF, EPS, or TIFF
- **Color**: RGB
- **Fonts**: Arial or Helvetica, minimum 8pt
- **Figure width**: Single (85 mm) or double (180 mm) column

**Tips:**
- High-quality, publication-ready figures
- Clear labeling and annotations
- Follow eLife style guide

#### General Guidelines

**Most journals require:**
- Minimum 300 DPI resolution
- Vector formats (PDF, EPS) or high-res raster (TIFF, PNG)
- Readable fonts (8-10pt minimum)
- Proper figure sizing (single/double column)
- Consistent styling

**Always check:**
- Journal's author guidelines
- Figure preparation instructions
- File format requirements
- Color mode requirements
- File size limits

### Figure Preparation Checklists

**Before submission:**
- [ ] All figures meet resolution requirements (300+ DPI)
- [ ] Figures are in required format (PDF, EPS, TIFF, etc.)
- [ ] All text is readable (minimum 8-10pt)
- [ ] Panels are properly labeled (A, B, C, etc.)
- [ ] Colors are colorblind-friendly (if possible)
- [ ] Figure sizes match journal requirements
- [ ] File sizes are within limits
- [ ] All figures are consistent in style
- [ ] Legends are clear and complete
- [ ] Source data/code is available if required

### Submission Formats

**Common formats:**
- **PDF**: Most versatile, vector format
- **EPS**: Some journals require for vector graphics
- **TIFF**: Required by some journals for raster images
- **PNG**: Accepted by some journals for web figures

**Preparation:**
- Export in required format
- Verify resolution and quality
- Check file size
- Test opening in different software
- Ensure fonts are embedded or converted to paths

---

## Section 10: Workflow: Combining Multiple Tools

A typical publication figure workflow combines multiple tools, each optimized for specific tasks.

### Typical Workflow

#### Step-by-Step Process

1. **Generate plots in R/Python**
   - Create individual plots
   - Export at high resolution (300+ DPI)
   - Use vector formats (PDF, SVG) when possible

2. **Export high-resolution versions**
   - Save as PDF or SVG for vector graphics
   - Save as PNG/TIFF at 300 DPI for raster
   - Keep source files (R/Python scripts)

3. **Import into Inkscape/Illustrator**
   - Import all panels
   - Arrange panels in desired layout
   - Use guides for alignment

4. **Arrange panels**
   - Position panels with proper spacing
   - Align consistently
   - Add panel labels (A, B, C, etc.)

5. **Add annotations**
   - Add text labels
   - Add arrows and highlights
   - Add scale bars if needed
   - Add legends if not in original plots

6. **Final export**
   - Export in journal-required format
   - Verify resolution and quality
   - Check file size

#### Visual Workflow Diagram

```
Complete Figure Creation Workflow:

┌──────────────────────────────────────────────────────────────┐
│                    STEP 1: Data Analysis                     │
│  ┌──────────┐         ┌──────────┐         ┌──────────┐      │
│  │   Data   │  ───→   │ Analysis │  ───→   │  Results │      │
│  └──────────┘         └──────────┘         └──────────┘      │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              STEP 2: Plot Generation (R/Python)              │
│                                                              │
│  R (ggplot2):                    Python (matplotlib):        │
│  ┌──────────────┐                ┌──────────────┐            │
│  │ ggplot(data) │                │ plt.plot()  │             │
│  │ + geom_*()   │                │ plt.show()  │             │
│  └──────┬───────┘                └──────┬───────┘            │
│         │                                │                   │
│         └──────────┬─────────────────────┘                   │
│                    ▼                                         │
│         Export: PDF/SVG/PNG (300+ DPI)                       │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│        STEP 3: Import & Arrange (Inkscape/Illustrator)        │
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ Panel 1  │  │ Panel 2  │  │ Panel 3  │  │ Panel 4  │    │
│  │ (PDF)    │  │ (PDF)    │  │ (PDF)    │  │ (PDF)    │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
│       │            │              │              │           │
│       └────────────┼──────────────┼─────────────┘           │
│                    ▼              ▼                          │
│            ┌──────────────────────────┐                      │
│            │   Arrange with Guides    │                      │
│            │   Align & Distribute     │                      │
│            └──────────────────────────┘                      │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              STEP 4: Annotation & Labeling                   │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Panel Labels │  │ Text Labels  │  │ Arrows/      │      │
│  │ (A, B, C, D) │  │ & Annotations│  │ Highlights   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ Scale Bars   │  │ Legends      │                        │
│  │ (if needed)  │  │ (if needed)  │                        │
│  └──────────────┘  └──────────────┘                        │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  STEP 5: Final Export                        │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   PDF        │  │   TIFF       │  │   PNG        │      │
│  │ (Vector)     │  │ (300+ DPI)   │  │ (300+ DPI)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ✓ Verify resolution (300+ DPI)                             │
│  ✓ Check file size                                           │
│  ✓ Test quality at actual size                               │
│  ✓ Match journal requirements                                │
└──────────────────────────────────────────────────────────────┘
```

### Example Workflows

#### Multi-Panel Figure from Scratch

**Scenario**: Creating a 4-panel figure with scatter plots, bar plot, heatmap, and schematic.

1. **R/Python**: Create 4 individual plots
   ```r
   # Panel A: Scatter plot
   p1 <- ggplot(data1, aes(x, y)) + geom_point() + theme_minimal()
   ggsave("panelA.pdf", p1, width=3.5, height=3.5, dpi=300)
   
   # Panel B: Bar plot
   p2 <- ggplot(data2, aes(x, y)) + geom_bar(stat="identity") + theme_minimal()
   ggsave("panelB.pdf", p2, width=3.5, height=3.5, dpi=300)
   
   # Panel C: Heatmap
   pheatmap(data_matrix, filename="panelC.pdf", width=3.5, height=3.5)
   
   # Panel D: Will create in draw.io or BioRender
   ```

2. **draw.io/BioRender**: Create schematic for Panel D
   - Export as PDF

3. **Inkscape**: Assemble all panels
   - Import all 4 PDFs
   - Arrange in 2x2 grid
   - Add panel labels (A, B, C, D)
   - Add figure title if needed
   - Export final figure as PDF

#### Combining Plots and Diagrams

**Scenario**: Adding a workflow diagram to a data visualization figure.

1. **R**: Create data plots
   - Export plots as PDF

2. **draw.io**: Create workflow diagram
   - Export as PDF

3. **Inkscape**: Combine
   - Import data plots
   - Import workflow diagram
   - Arrange appropriately
   - Add connecting elements if needed
   - Export combined figure

#### Adding Schematics to Data Plots

**Scenario**: Adding an experimental schematic above data plots.

1. **BioRender**: Create experimental schematic
   - Export as PDF or PNG (high res)

2. **R/Python**: Create data plots
   - Export as PDF

3. **Inkscape**: Combine
   - Import schematic (place at top)
   - Import data plots (arrange below)
   - Add panel labels
   - Ensure consistent styling
   - Export final figure

### Workflow Tips

- **Start with high quality**: Export plots at high resolution from the start
- **Use vector formats**: PDF/SVG when possible for scalability
- **Keep source files**: Maintain R/Python scripts and vector graphics files
- **Document process**: Note software versions and key parameters
- **Test early**: Check figure quality and requirements early in the process
- **Iterate**: Don't be afraid to go back and regenerate plots if needed

---

## Section 11: Common Mistakes and Troubleshooting

Avoiding common mistakes saves time and ensures your figures meet publication standards.

### Low Resolution Issues

**Problem**: Figures appear pixelated or blurry when printed.

**Solutions:**
- Always export at 300+ DPI
- Use vector formats (PDF, SVG) when possible
- Check actual DPI in exported files
- Avoid upscaling low-resolution images

**Prevention:**
- Set DPI explicitly in export commands
- Verify DPI before finalizing figures
- Test print quality at actual size

### Font Embedding Problems

**Problem**: Fonts don't display correctly when figures are opened on other computers.

**Solutions:**
- **In Inkscape**: Convert text to paths (Path → Object to Path)
- **In R**: Use `extrafont` package to embed fonts
- **In Python**: Specify font paths explicitly
- Use standard fonts (Arial, Helvetica, Times)

**Prevention:**
- Convert text to paths before final export
- Use fonts that are likely to be available
- Test figures on different computers

### Color Space Mismatches

**Problem**: Colors appear different in print vs screen.

**Solutions:**
- Convert RGB to CMYK if journal requires
- Use color profiles consistently
- Test color appearance in target medium
- Use colorblind-friendly palettes

**Prevention:**
- Check journal color requirements early
- Use appropriate color space from the start
- Test color conversion if needed

### File Size Issues

**Problem**: Figure files are too large for journal submission.

**Solutions:**
- Compress raster images (use LZW compression for TIFF)
- Optimize vector graphics
- Reduce image dimensions if appropriate
- Use appropriate format (vector for simple graphics)

**Prevention:**
- Monitor file sizes during creation
- Use compression when exporting
- Optimize images before final export

### Alignment Problems

**Problem**: Panels are misaligned or inconsistently spaced.

**Solutions:**
- Use alignment tools in Inkscape/Illustrator
- Use guides and grids
- Distribute objects evenly
- Group aligned objects to maintain alignment

**Prevention:**
- Use alignment tools from the start
- Set up guides before arranging panels
- Check alignment before final export

### Other Common Issues

**Text too small:**
- Increase font size to minimum 8-10pt
- Test readability at actual print size

**Inconsistent styling:**
- Create style guide
- Use consistent fonts, colors, sizes
- Copy/paste styles when possible

**Missing panel labels:**
- Always add panel labels (A, B, C, etc.)
- Place consistently (usually top-left)
- Use consistent styling

**Poor color choices:**
- Use colorblind-friendly palettes
- Test with colorblind simulators
- Don't rely solely on color

---

## Section 12: Resources and Examples

### Online Resources

**Tutorials and Guides:**
- **ggplot2 documentation**: https://ggplot2.tidyverse.org/
- **matplotlib tutorials**: https://matplotlib.org/stable/tutorials/
- **Inkscape tutorials**: https://inkscape.org/learn/tutorials/
- **draw.io guides**: https://www.diagrams.net/doc/

**Color Resources:**
- **ColorBrewer**: https://colorbrewer2.org/
- **Viridis**: https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
- **Color Oracle**: Colorblind simulator
- **Coblis**: Online colorblind simulator

**Figure Galleries:**
- **Data Visualization Society**: https://www.datavisualizationsociety.com/
- **R Graph Gallery**: https://r-graph-gallery.com/
- **Python Graph Gallery**: https://python-graph-gallery.com/

### Software Documentation

- **R/ggplot2**: Comprehensive documentation and cheatsheets
- **Python/matplotlib**: Extensive tutorials and examples
- **Inkscape**: User manual and video tutorials
- **draw.io**: Help center and templates
- **BioRender**: Help center and icon library

### Example Workflows

**Complete example**: Creating a publication figure from data to final PDF
1. Data analysis in R
2. Plot generation with ggplot2
3. Export as PDF
4. Assembly in Inkscape
5. Final export

**Templates and examples**: Many journals provide figure templates and examples

### Best Practices Summary

1. **Start with quality**: Export at high resolution from the start
2. **Use appropriate tools**: Right tool for each task
3. **Follow guidelines**: Check journal requirements early
4. **Test thoroughly**: Verify quality and requirements
5. **Document process**: Keep source files and notes
6. **Iterate and improve**: Don't settle for "good enough"

---

## Conclusion

Creating publication-ready figures is a skill that improves with practice. This guide has covered the essential tools, techniques, and best practices needed to create professional scientific figures.

### Summary of Key Points

- **Choose appropriate tools** for each task (R/Python for plots, Inkscape for assembly, etc.)
- **Export at high resolution** (300+ DPI) from the start
- **Use vector formats** (PDF, SVG) when possible
- **Follow journal requirements** for formats, resolution, and styling
- **Test figure quality** before submission
- **Keep source files** for reproducibility

### Recommended Workflow

1. Generate plots in R or Python
2. Export at high resolution (300+ DPI) in vector format (PDF/SVG)
3. Assemble panels in Inkscape (or Illustrator)
4. Add annotations and labels
5. Export final figure in journal-required format
6. Verify quality and requirements

### Final Tips

- **Practice regularly**: The more you create figures, the better you'll become
- **Learn from examples**: Study well-designed figures in published papers
- **Seek feedback**: Get input from colleagues on figure clarity
- **Stay updated**: Tools and best practices evolve
- **Document your process**: Makes future figure creation easier

Remember: Good figures are essential for effective scientific communication. Invest time in creating high-quality, publication-ready figures—it's worth the effort.

---

*This guide provides a comprehensive foundation for creating publication-ready scientific figures. Each project may have unique requirements, so always check your target journal's specific guidelines and adapt these practices accordingly.*

