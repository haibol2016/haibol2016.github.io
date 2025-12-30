---
layout: post
title: "Conda Environment and Container Management Best Practices for Nextflow"
date: 2025-12-22
categories: [bioinformatics, nextflow, workflows]
tags: [nextflow, containers, conda, docker, singularity, bioinformatics, workflows, best-practices]
author: Haibo Liu, PhD
---


## Introduction

Nextflow pipelines require specific software tools and dependencies to execute successfully. Managing these dependencies across different computing environments (development machines, HPC clusters, cloud platforms) can be challenging due to version conflicts, missing libraries, and platform-specific requirements. This is where **conda/mamba environments** and **containers** (Docker, Singularity, Podman) become essential.

**Conda/Mamba environments** provide isolated package management, allowing you to define exact versions of tools and their dependencies. They create reproducible environments that can be shared across platforms, though they require the tools to be installed at runtime.

**Containers** (Docker, Singularity, Apptainer, Podman) package entire software stacks—including the operating system, tools, and dependencies—into portable, self-contained units. This ensures that pipelines run identically across different systems, eliminating the "it works on my machine" problem. Containers are particularly valuable for:

- **Reproducibility**: Exact same environment every time
- **Portability**: Run on any system that supports containers
- **Isolation**: No conflicts with system software
- **Consistency**: Same results across development, testing, and production

Nextflow seamlessly integrates with both approaches, allowing you to specify environments or containers for each process, ensuring your pipelines are reproducible, portable, and maintainable.

This guide provides best practices for using conda/mamba environments and Docker/Singularity containers in Nextflow pipelines, including building cross-platform images.


## Overview

Nextflow supports multiple containerization strategies:

- **Conda/Mamba**: Environment-based package management
- **Docker**: Application containerization
- **Singularity/Apptainer**: HPC-friendly containerization
- **Podman**: Docker-compatible alternative

Each has different use cases, advantages, and configuration requirements.

### When to Use Each

| Environment/Container Type | Best For | Advantages | Limitations |
|----------------------------|----------|------------|-------------|
| **Conda/Mamba** (Environments) | Development, quick setup | Easy package management, version control | Slower execution, dependency conflicts |
| **Docker** (Containers) | Production, CI/CD | Fast, reproducible, widely supported | Requires Docker daemon, root access |
| **Singularity** (Containers) | HPC clusters | No root access, security, performance | Requires Singularity installation |
| **Podman** (Containers) | Rootless containers | Security, Docker-compatible | Less mature ecosystem |

---

## Conda/Mamba Environments

### Overview

Conda and Mamba use environment files (`environment.yml`) to define package dependencies. Nextflow automatically creates and manages conda environments. Unlike Docker/Singularity containers, conda/mamba create isolated environments rather than full containers.

### Creating Environment Files

**Basic Structure (`environment.yml`):**

```yaml
name: tool_environment
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - tool_name=1.2.3
  - dependency1>=2.0.0
  - dependency2
```

**Example for a Nextflow Module:**

```yaml
# modules/nf-core/tool/process/environment.yml
name: tool_environment
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - tool_name=1.2.3
  - python=3.9
  - samtools=1.15
```

### Best Practices for Conda/Mamba

1. **Pin Versions:**
   ```yaml
   dependencies:
     - tool_name=1.2.3  # Pinned version
     - dependency>=2.0.0  # Minimum version
   ```

2. **Use Bioconda/Biocontainers Channels:**
   ```yaml
   channels:
     - bioconda  # For bioinformatics tools
     - conda-forge  # For general packages
     - defaults
   ```

3. **Specify Channel Priority:**
   ```yaml
   channels:
     - bioconda
     - conda-forge
     - defaults
   channel_priority: strict  # Prefer earlier channels
   ```

4. **Minimize Dependencies:**
   ```yaml
   # ✅ Good: Only essential dependencies
   dependencies:
     - tool_name=1.2.3
     - python=3.9
   
   # ❌ Avoid: Unnecessary dependencies
   dependencies:
     - tool_name=1.2.3
     - python=3.9
     - jupyter  # Not needed for CLI tool
   ```

5. **Use Mamba for Faster Resolution:**
   ```bash
   # In nextflow.config
   conda {
       useMamba = true  # Faster than conda
   }
   ```

### Module Configuration

**In `main.nf`:**

```groovy
process TOOL {
    // Conda environment is automatically used if environment.yml exists
    // No explicit container declaration needed
    
    conda "${moduleDir}/environment.yml"
    
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

**In `nextflow.config`:**

```groovy
conda {
    enabled = true
    useMamba = true  // Use mamba instead of conda (faster)
    cacheDir = "${workDir}/conda"  // Cache directory
}
```

### Limitations

- **Not Available for All Tools**: Some tools are not in bioconda/biocontainers
- **Dependency Conflicts**: Can occur with complex dependency trees
- **Slower Execution**: Environment creation takes time (compared to pre-built containers)
- **Platform-Specific**: Some packages may not be available on all platforms
- **Not True Containers**: Environments provide isolation but not the same level as containers

---

## Docker Containers

### Overview

Docker containers provide isolated, reproducible environments. Nextflow can pull and use Docker images from registries like Docker Hub, Quay.io, and GitHub Container Registry.

### Finding Available Images

**Common Registries:**

1. **Quay.io (Biocontainers):**
   ```text
   quay.io/biocontainers/tool_name:version--build
   ```

2. **Docker Hub:**
   ```text
   tool_name:version
   ```

3. **GitHub Container Registry:**
   ```text
   ghcr.io/organization/tool_name:version
   ```

**Checking Image Availability:**

```bash
# Check if image exists
docker pull quay.io/biocontainers/tool_name:version

# List available tags
curl -s https://quay.io/api/v1/repository/biocontainers/tool_name/tag/ | jq '.tags[].name'
```

### Module Configuration

**In `main.nf`:**

```groovy
process TOOL {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://quay.io/biocontainers/tool_name:1.2.3--build' :
        'quay.io/biocontainers/tool_name:1.2.3--build' }"
    
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

**Best Practice Pattern:**

```groovy
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'docker://quay.io/biocontainers/tool_name:1.2.3--build' :
    'quay.io/biocontainers/tool_name:1.2.3--build' }"
```

This pattern:
- Uses `docker://` prefix for Singularity when needed
- Falls back to regular Docker format
- Works with both Docker and Singularity

### Dockerfile Best Practices

**Basic Dockerfile:**

```dockerfile
FROM quay.io/biocontainers/base_image:tag

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    additional-tool \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /data

# Set entrypoint or command
ENTRYPOINT ["tool"]
```

**Multi-Stage Build (for Custom Tools):**

```dockerfile
# Build stage
FROM python:3.9-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone and build tool
RUN git clone https://github.com/org/tool.git && \
    cd tool && \
    python setup.py install

# Runtime stage
FROM python:3.9-slim

# Copy built tool from builder
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin/tool /usr/local/bin/tool

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    runtime-deps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

ENTRYPOINT ["tool"]
```

### Building Docker Images

**Basic Build:**

```bash
# Build image
docker build -t tool_name:version .

# Tag for registry
docker tag tool_name:version quay.io/organization/tool_name:version

# Push to registry
docker push quay.io/organization/tool_name:version

# For more details, see [docker official documentation](https://docs.docker.com/)
```

**Build with BuildKit (for cross-platform):**

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build for specific platform
docker build --platform linux/amd64 -t tool_name:version .

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t tool_name:version .
```

## Using Customized Docker Images in Nextflow Modules

### Overview

When a tool is not available in standard container registries (like biocontainers), you can create a custom Dockerfile within the module directory and build a custom Docker image. This is particularly useful for:

- Tools not available in bioconda/biocontainers
- Tools requiring custom build steps or dependencies
- Tools with complex workflows that need wrapper scripts
- Proprietary or custom tools

### When to Use Custom Docker Images

**✅ Use Custom Docker Images When:**

- Tool is not available in `quay.io/biocontainers/` or Docker Hub
- Tool requires specific build configurations
- Tool needs wrapper scripts to match module interface
- Tool has complex dependencies not easily managed via conda

**❌ Avoid Custom Docker Images When:**

- Tool is available in biocontainers (use existing image)
- Tool can be installed via conda (use `environment.yml`)
- Simple tools that work with standard images

### Creating a Custom Dockerfile

**Location:** Place the Dockerfile in the module directory:

```text
modules/nf-core/tool/process/
├── Dockerfile          # Custom Dockerfile
├── main.nf            # Module definition
├── meta.yml           # Module metadata
└── environment.yml    # Optional: conda fallback
```

**Basic Dockerfile Structure:**

```dockerfile
# Dockerfile for Tool Name
# Based on: https://github.com/org/tool

FROM python:3.9-slim

# Set working directory
WORKDIR /opt

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    tool-dependencies \
    && rm -rf /var/lib/apt/lists/*

# Install tool from source
RUN git clone https://github.com/org/tool.git /opt/tool && \
    cd /opt/tool && \
    python setup.py install

# Create wrapper script if needed
RUN mkdir -p /opt/tool-wrapper && \
    cat > /opt/tool-wrapper/tool_wrapper.py << 'EOF'
#!/usr/bin/env python3
# Wrapper script implementation
EOF
RUN chmod +x /opt/tool-wrapper/tool_wrapper.py && \
    ln -s /opt/tool-wrapper/tool_wrapper.py /usr/local/bin/tool

# Set PATH
ENV PATH="/opt/tool/bin:${PATH}"

# Set default working directory
WORKDIR /workspace

CMD ["/bin/bash"]
```

### Example: RibORF 2.0 Custom Dockerfile

**Real-world example from `modules/nf-core/riboorf/predict/Dockerfile`:**

```dockerfile
# Dockerfile for RiboORF 2.0
# Based on: https://github.com/zhejilab/RibORF/tree/master/RibORF.2.0

FROM python:3.9-slim

WORKDIR /opt

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    perl \
    r-base \
    samtools \
    bowtie \
    wget \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install gtfToGenePred from UCSC
RUN wget -q https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred \
    -O /usr/local/bin/gtfToGenePred && \
    chmod +x /usr/local/bin/gtfToGenePred

# Install Perl dependencies
RUN curl -L https://cpanmin.us | perl - App::cpanminus

# Clone and setup RibORF
RUN git clone --depth 1 --branch master \
    https://github.com/zhejilab/RibORF.git /opt/RibORF

WORKDIR /opt/RibORF/RibORF.2.0
RUN chmod +x *.pl

# Create Python wrapper script
RUN mkdir -p /opt/riborf-wrapper && \
    cat > /opt/riborf-wrapper/riborf_wrapper.py << 'WRAPPER_EOF'
#!/usr/bin/env python3
# Wrapper implementing full RibORF 2.0 workflow
# ... wrapper script implementation ...
WRAPPER_EOF

RUN chmod +x /opt/riborf-wrapper/riborf_wrapper.py && \
    ln -s /opt/riborf-wrapper/riborf_wrapper.py /usr/local/bin/RiboORF

# Add to PATH
ENV PATH="/opt/RibORF/RibORF.2.0:${PATH}"

WORKDIR /workspace
CMD ["/bin/bash"]
```

### Module Configuration with Custom Image

**In `main.nf`:**

```groovy
process TOOL {
    tag "$meta.id"
    label 'process_medium'

    // Reference custom Docker image
    // Option 1: Use Docker Hub or custom registry
    container "docker.io/username/tool:version"
    
    // Option 2: Use local image (requires pre-building)
    // container "tool:version"
    
    // Option 3: Conditional for Singularity compatibility
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/username/tool:version' :
        'docker.io/username/tool:version' }"

    input:
    path input_file

    output:
    path output_file

    script:
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

**Profile Compatibility Check:**

```groovy
process TOOL {
    // ... container declaration ...
    
    script:
    // Check if tool supports conda/mamba profile
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "TOOL module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

### Building Custom Docker Images

**Build from Module Directory:**

```bash
# Navigate to module directory
cd modules/nf-core/tool/process/

# Build image
docker build -t tool:version -f Dockerfile .

# Tag for registry
docker tag tool:version docker.io/username/tool:version

# Push to registry
docker push docker.io/username/tool:version
```

**Build with Build Context:**

```bash
# Build from project root (if Dockerfile references files outside module)
docker build -t tool:version \
    -f modules/nf-core/tool/process/Dockerfile \
    modules/nf-core/tool/process/
```

**Build for Multiple Platforms:**

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build for multiple platforms
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag docker.io/username/tool:version \
    --push \
    -f modules/nf-core/tool/process/Dockerfile \
    modules/nf-core/tool/process/
```

### Publishing Custom Images

**1. Docker Hub:**

```bash
# Login
docker login

# Build and tag
docker build -t username/tool:version -f Dockerfile .
docker tag username/tool:version username/tool:latest

# Push
docker push username/tool:version
docker push username/tool:latest
```

**2. Quay.io:**

```bash
# Login
docker login quay.io

# Build and tag
docker build -t quay.io/organization/tool:version -f Dockerfile .
docker tag quay.io/organization/tool:version quay.io/organization/tool:latest

# Push
docker push quay.io/organization/tool:version
docker push quay.io/organization/tool:latest
```

**3. GitHub Container Registry:**

```bash
# Login
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Build and tag
docker build -t ghcr.io/organization/tool:version -f Dockerfile .
docker tag ghcr.io/organization/tool:version ghcr.io/organization/tool:latest

# Push
docker push ghcr.io/organization/tool:version
docker push ghcr.io/organization/tool:latest
```

### Documentation Requirements

**Create `README.md` in Module Directory:**

```markdown
# Tool Docker Image

This directory contains a custom Dockerfile for building a Docker image with Tool installed.

## Building the Docker Image

### Prerequisites

- Docker installed and running
- Git (for cloning repositories if needed)

### Build Commands

```bash
# Basic build
docker build -t tool:version -f Dockerfile .

# Build for specific platform
docker build --platform linux/amd64 -t tool:version -f Dockerfile .

# Build and tag for registry
docker build -t quay.io/organization/tool:version -f Dockerfile .
```

### Publishing

```bash
# Tag for registry
docker tag tool:version quay.io/organization/tool:version

# Push to registry
docker push quay.io/organization/tool:version
```

### Using the Image

The module automatically uses this image when running with Docker/Singularity profiles:

```bash
nextflow run pipeline.nf -profile docker
```

## Image Details

- **Base Image**: python:3.9-slim
- **Tool Version**: 2.0
- **Source**: <https://github.com/org/tool>

### Best Practices for Custom Dockerfiles

**1. Use Minimal Base Images:**

```dockerfile
# ✅ Good: Minimal base image
FROM python:3.9-slim

# ❌ Avoid: Full OS image
FROM ubuntu:latest
```

**2. Clean Up in Same Layer:**

```dockerfile
# ✅ Good: Clean up in same RUN
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ❌ Bad: Separate RUN commands
RUN apt-get update
RUN apt-get install -y package
```

**3. Use Multi-Stage Builds When Appropriate:**

```dockerfile
# Build stage
FROM python:3.9-slim as builder
WORKDIR /build
# ... build steps ...

# Runtime stage
FROM python:3.9-slim
COPY --from=builder /usr/local /usr/local
# ... runtime setup ...
```

**4. Create Wrapper Scripts for Complex Workflows:**

```dockerfile
# Create wrapper that implements full workflow
RUN cat > /usr/local/bin/tool << 'EOF'
#!/bin/bash
# Step 1: Preprocessing
preprocess "$@"

# Step 2: Main analysis
analyze "$@"

# Step 3: Post-processing
postprocess "$@"
EOF
RUN chmod +x /usr/local/bin/tool
```

**5. Version Detection:**

```dockerfile
# Create version file or Python package for version detection
RUN mkdir -p /usr/local/lib/python3.9/site-packages/Tool && \
    printf '__version__ = "2.0"\n' > \
    /usr/local/lib/python3.9/site-packages/Tool/__init__.py
```

**6. Test Installation:**

```dockerfile
# Verify installation at build time
RUN tool --version && \
    python3 -c "import Tool; print(Tool.__version__)" && \
    echo "Tool installation verified"
```

### Integration with Nextflow

**1. Update Module `main.nf`:**

```groovy
process TOOL {
    container "docker.io/username/tool:version"
    // ... rest of process ...
}
```

**2. Document in Module `meta.yml`:**

```yaml
tools:
  - tool:
      name: Tool
      description: Tool description
      homepage: https://github.com/org/tool
      documentation: https://github.com/org/tool/wiki
      tool_dev_url: https://github.com/org/tool
      doi: ""
      licence: ['MIT']
      # Note: Custom Docker image required
```

**3. Update Pipeline Documentation:**

```markdown
## Custom Docker Images

Some modules require custom Docker images:

- **RibORF 2.0**: Custom Dockerfile in `modules/nf-core/riboorf/predict/`
  - Build: `docker build -t riboorf:2.0 -f modules/nf-core/riboorf/predict/Dockerfile .`
  - Image: `docker.io/username/riboorf:2.0`
```

### Troubleshooting Custom Images

**1. Image Not Found:**

```bash
# Verify image exists locally
docker images | grep tool

# Pull from registry if needed
docker pull docker.io/username/tool:version

# Test image
docker run --rm docker.io/username/tool:version tool --version
```

**2. Build Failures:**

```bash
# Build with verbose output
docker build --progress=plain -t tool:version -f Dockerfile .

# Check intermediate layers
docker build --target builder -t tool:builder -f Dockerfile .
docker run --rm tool:builder /bin/bash
```

**3. Permission Issues:**

```dockerfile
# Use non-root user in Dockerfile
RUN useradd -m -u 1000 user
USER user
WORKDIR /home/user
```

**4. Platform-Specific Issues:**

```bash
# Build for specific platform
docker build --platform linux/amd64 -t tool:version -f Dockerfile .

# Test on target platform
docker run --rm --platform linux/amd64 tool:version tool --version
```

---

## Singularity Containers

### Overview

Singularity (now Apptainer) is designed for HPC environments where Docker is not available or allowed.

### Module Configuration

**In `main.nf`:**

```groovy
process TOOL {
    // Singularity automatically converts Docker URLs
    container 'docker://quay.io/biocontainers/tool_name:1.2.3--build'
    
    // Or use Singularity-specific format
    container "${ workflow.containerEngine == 'singularity' ?
        'docker://quay.io/biocontainers/tool_name:1.2.3--build' :
        'quay.io/biocontainers/tool_name:1.2.3--build' }"
    
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

### Singularity Definition Files

**Basic Definition File (`tool.def`):**

```singularity
Bootstrap: docker
From: quay.io/biocontainers/tool_name:1.2.3--build

%environment
    export PATH=/usr/local/bin:$PATH

%runscript
    exec tool "$@"
```

**Building Singularity Images:**

```bash
# Build from Docker image
singularity build tool.sif docker://quay.io/biocontainers/tool_name:1.2.3--build

# Build from definition file
singularity build tool.sif tool.def

# Build with cache
singularity build --fakeroot tool.sif tool.def
```

### Platform-Specific Considerations for Singularity

**Yes, Singularity images can have platform-specific issues**
similar to Docker containers:

**1. Architecture Inheritance:**

Singularity images built from Docker images inherit the architecture of the source Docker image:

```bash
# Build from AMD64 Docker image (creates AMD64 Singularity image)
singularity build tool.sif docker://quay.io/biocontainers/tool:1.2.3

# The resulting .sif file will be for the same architecture as the source
```

**2. Cross-Platform Execution:**

Singularity can run images built for different architectures, but with limitations:

- **Native execution**: Fastest, works best when image architecture matches host
- **Cross-architecture execution**: May work but can have compatibility issues
  - AMD64 images on ARM64 hosts: May work but slower, some binaries may fail
  - ARM64 images on AMD64 hosts: Generally works better due to emulation support

**3. Building on Different Platforms:**

```bash
# Build on AMD64 system
singularity build tool_amd64.sif docker://quay.io/biocontainers/tool:1.2.3

# Build on ARM64 system (if ARM64 image available)
singularity build tool_arm64.sif docker://quay.io/biocontainers/tool:1.2.3--arm64

# Check image architecture
singularity inspect tool.sif | grep Architecture
```

**4. Platform-Specific Build Issues:**

**On macOS ARM64 (Apple Silicon):**

```bash
# Singularity/Apptainer on macOS requires Linux VM or Docker
# Option 1: Use Docker to build Singularity images
docker run --privileged -v $(pwd):/work -w /work \
    quay.io/singularity/singularity:v3.11.0 \
    build tool.sif docker://quay.io/biocontainers/tool:1.2.3

# Option 2: Use remote builder (if available)
singularity build --remote tool.sif docker://quay.io/biocontainers/tool:1.2.3
```

**On Linux ARM64:**

```bash
# Build directly (if Singularity installed)
singularity build tool.sif docker://quay.io/biocontainers/tool:1.2.3

# Note: If source Docker image is AMD64, the Singularity image will be AMD64
# This may cause performance issues or compatibility problems
```

**5. Checking Image Architecture:**

```bash
# Inspect Singularity image architecture
singularity inspect tool.sif

# Check specific architecture field
singularity inspect tool.sif | grep -i arch

# Or use file command
file tool.sif
```

**6. Platform-Aware Building:**

```bash
# Build for specific platform (if source supports it)
# Note: Singularity doesn't have direct --platform flag like Docker
# The platform is determined by the source Docker image

# Check Docker image platforms first
docker manifest inspect quay.io/biocontainers/tool:1.2.3 | jq '.manifests[].platform'

# Build from specific platform Docker image
# If multi-platform Docker image exists, Singularity will use the default
# To force a specific platform, you may need to:
# 1. Pull the specific platform Docker image first
# 2. Build Singularity from local Docker image
docker pull --platform linux/amd64 quay.io/biocontainers/tool:1.2.3
singularity build tool.sif docker-daemon://tool:1.2.3
```

**7. Best Practices for Platform Compatibility:**

**✅ Do:**

- Build Singularity images on the target platform when possible
- Verify image architecture matches your compute nodes
- Test images on target architecture before production use
- Use multi-platform Docker images as sources when available

**❌ Don't:**

- Assume AMD64 Singularity images will work on ARM64 without testing
- Build on one platform and expect perfect compatibility on another
- Ignore architecture warnings during build

**8. Troubleshooting Platform Issues:**

#### Issue: "exec format error" or "cannot execute binary file"

```bash
# Problem: Architecture mismatch
# Solution: Check and match architectures

# Check host architecture
uname -m  # Should show x86_64 (AMD64) or aarch64 (ARM64)

# Check image architecture
singularity inspect tool.sif | grep Architecture

# Rebuild from correct platform Docker image
docker pull --platform linux/amd64 quay.io/biocontainers/tool:1.2.3
singularity build tool.sif docker-daemon://tool:1.2.3
```

#### Issue: Slow performance on ARM64 with AMD64 images

```bash
# Problem: Running AMD64 Singularity image on ARM64 host
# Solutions:

# Option 1: Use ARM64-native image if available
singularity build tool.sif docker://quay.io/biocontainers/tool:1.2.3--arm64

# Option 2: Use conda/mamba instead
nextflow run pipeline.nf -profile conda

# Option 3: Accept performance penalty (may be acceptable)
```

#### Issue: Build fails on macOS

```bash
# Problem: Singularity not natively available on macOS
# Solutions:

# Option 1: Use Docker to build Singularity images
docker run --privileged -v $(pwd):/work -w /work \
    quay.io/singularity/singularity:v3.11.0 \
    build tool.sif docker://quay.io/biocontainers/tool:1.2.3

# Option 2: Use remote builder
singularity build --remote tool.sif docker://quay.io/biocontainers/tool:1.2.3

# Option 3: Build on Linux system or HPC cluster
```

**9. Nextflow Configuration for Platform-Aware Singularity:**

```groovy
// In nextflow.config
singularity {
    enabled = true
    autoMounts = true
    cacheDir = "${workDir}/singularity"
    
    // Platform-specific options
    runOptions = '-B /data:/data'
    
    // For ARM64 systems running AMD64 images
    // May need additional options depending on your setup
}

// Profile for ARM64 systems
profiles {
    singularity_arm64 {
        singularity.enabled = true
        singularity.autoMounts = true
        // May need to specify platform-specific images
    }
}
```

**10. Summary:**

- **Singularity images inherit platform from source Docker images**
- **Cross-platform execution is possible but may have issues**
- **Build on target platform when possible for best compatibility**
- **Test images on target architecture before production use**
- **Use platform-specific Docker images as sources when available**

### Nextflow Configuration

**In `nextflow.config`:**

```groovy
singularity {
    enabled = true
    autoMounts = true
    cacheDir = "${workDir}/singularity"
    runOptions = '-B /data:/data'  // Bind mounts
}
```

---

## macOS ARM64 (Apple Silicon) Considerations

### Overview

macOS on Apple Silicon (M1/M2/M3) uses ARM64 architecture, which requires special considerations when running Nextflow pipelines with containers. Most bioinformatics containers are built for `linux/amd64`, which can cause compatibility issues.

### Key Challenges

1. **Architecture Mismatch**: Most containers are built for `linux/amd64`, not `linux/arm64`
2. **Performance**: Running amd64 containers on ARM64 requires emulation (slower)
3. **Availability**: Not all tools have ARM64-native images available
4. **Build Requirements**: Building images may require platform-specific considerations

### Docker Desktop on macOS ARM64

**Platform Emulation:**

Docker Desktop on macOS automatically handles platform emulation using Rosetta 2, but this comes with performance overhead:

```bash
# Check Docker platform
docker version

# Check if running in emulation mode
docker run --rm --platform linux/amd64 alpine uname -m  # x86_64 (emulated)
docker run --rm --platform linux/arm64 alpine uname -m  # aarch64 (native)
```

**Performance Comparison:**

- **Native ARM64**: Fastest (if image available)
- **Emulated AMD64**: 2-3x slower, but compatible with most images
- **Mixed**: Some processes native, some emulated

### Nextflow Configuration for macOS ARM64

**Option 1: Use `emulate_amd64` Profile (Recommended for Compatibility)**

Force all containers to run as `linux/amd64` using emulation:

```groovy
// In nextflow.config
profiles {
    emulate_amd64 {
        docker.runOptions = '-u $(id -u):$(id -g) --platform=linux/amd64'
    }
}
```

**Usage:**

```bash
# Run with AMD64 emulation
nextflow run pipeline.nf -profile docker,emulate_amd64
```

**Option 2: Use `arm64` Profile with Wave**

Use Wave to automatically build ARM64-compatible containers:

```groovy
// In nextflow.config
profiles {
    arm64 {
        process.arch = 'arm64'
        apptainer.ociAutoPull = true
        singularity.ociAutoPull = true
        wave.enabled = true
        wave.freeze = true
        wave.strategy = 'conda,container'
    }
}
```

**Usage:**

```bash
# Run with ARM64 profile (requires Wave)
nextflow run pipeline.nf -profile docker,arm64
```

#### Option 3: Native ARM64 (When Available)

If images support ARM64 natively:

```bash
# Check if image has ARM64 support
docker manifest inspect quay.io/biocontainers/tool:version | grep architecture

# Run natively (if supported)
nextflow run pipeline.nf -profile docker
```

### Module Configuration for macOS ARM64

**In `main.nf` - Platform-Aware Container Selection:**

```groovy
process TOOL {
    // Detect platform and select appropriate container
    container = { 
        def platform = System.getProperty('os.arch')
        if (platform == 'aarch64' || platform.contains('arm')) {
            // Try ARM64-native image first, fallback to AMD64
            def arm64Image = 'quay.io/biocontainers/tool:1.2.3--arm64'
            def amd64Image = 'quay.io/biocontainers/tool:1.2.3--build'
            // Check if ARM64 image exists, otherwise use AMD64 with emulation
            return amd64Image  // Most common: use AMD64 with emulation
        } else {
            return 'quay.io/biocontainers/tool:1.2.3--build'
        }
    }
    
    // Or use workflow container engine settings
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://quay.io/biocontainers/tool:1.2.3--build' :
        'quay.io/biocontainers/tool:1.2.3--build' }"
    
    // ... rest of process
}
```

**Force AMD64 Platform in Docker Run Options:**

```groovy
// In nextflow.config or modules.config
docker {
    runOptions = '-u $(id -u):$(id -g) --platform=linux/amd64'
}
```

### Building Images for macOS ARM64

**Build Native ARM64 Images:**

```bash
# Build for ARM64 (native on Apple Silicon)
docker build --platform linux/arm64 -t tool:arm64 .

# Test native performance
docker run --rm --platform linux/arm64 tool:arm64 tool --version
```

**Build Multi-Platform Images:**

```bash
# Create buildx builder
docker buildx create --name multiarch --use

# Build for both platforms
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag tool:version \
    --push \
    .
```

**Build AMD64 Images on ARM64 (for Compatibility):**

```bash
# Build AMD64 image on ARM64 Mac (uses emulation)
docker build --platform linux/amd64 -t tool:amd64 .

# Verify architecture
docker inspect tool:amd64 | grep Architecture  # Should show "amd64"
```

### Performance Optimization

**1. Use Native ARM64 When Possible:**

```bash
# Check for ARM64-native images
docker manifest inspect quay.io/biocontainers/tool:version

# Use native if available
docker pull --platform linux/arm64 quay.io/biocontainers/tool:version
```

**2. Increase Docker Resources:**

In Docker Desktop settings:
- **Memory**: Allocate at least 8GB (16GB recommended)
- **CPUs**: Use at least 4 cores
- **Disk**: Ensure sufficient space for images

**3. Use BuildKit for Faster Builds:**

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

docker build --platform linux/amd64 -t tool:version .
```

**4. Cache Layers Effectively:**

```dockerfile
# Order Dockerfile to maximize cache hits
FROM python:3.9-slim

# Install dependencies first (cached)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy code last (changes frequently)
COPY app/ /app/
```

### Troubleshooting macOS ARM64 Issues

**1. "exec format error" or "cannot execute binary file":**

```bash
# Problem: Trying to run ARM64 binary in AMD64 container or vice versa
# Solution: Force platform in docker runOptions

# In nextflow.config
docker {
    runOptions = '--platform=linux/amd64'
}
```

**2. Slow Performance:**

```bash
# Problem: Running AMD64 containers on ARM64 (emulation overhead)
# Solutions:

# Option 1: Use native ARM64 images if available
docker pull --platform linux/arm64 quay.io/biocontainers/tool:version

# Option 2: Increase Docker Desktop resources
# Docker Desktop → Settings → Resources → Increase Memory/CPUs

# Option 3: Use conda/mamba instead of containers
nextflow run pipeline.nf -profile conda
```

**3. Image Not Found for ARM64:**

```bash
# Problem: Image doesn't have ARM64 variant
# Solution: Use AMD64 with emulation

# In nextflow.config
profiles {
    emulate_amd64 {
        docker.runOptions = '--platform=linux/amd64'
    }
}

# Usage
nextflow run pipeline.nf -profile docker,emulate_amd64
```

**4. Build Failures on ARM64:**

```bash
# Problem: Building image fails due to architecture-specific issues
# Solution: Build for specific platform

# Build for AMD64 (even on ARM64 Mac)
docker build --platform linux/amd64 -t tool:version .

# Or use buildx for cross-platform
docker buildx build --platform linux/amd64 -t tool:version .
```

**5. Check Platform Compatibility:**

```bash
# Check current platform
uname -m  # Should show "arm64" on Apple Silicon

# Check Docker platform
docker version --format '{{.Server.Arch}}'

# Check image platform
docker inspect image:tag | grep Architecture

# Test container platform
docker run --rm image:tag uname -m
```

### Best Practices for macOS ARM64

**1. Default to AMD64 Emulation:**

```groovy
// In nextflow.config - make emulate_amd64 the default for macOS
if (System.getProperty('os.name').toLowerCase().contains('mac')) {
    docker.runOptions = '--platform=linux/amd64'
}
```

**2. Document Platform Requirements:**

```markdown
## macOS ARM64 (Apple Silicon) Users

This pipeline has been tested on macOS ARM64. For best compatibility:

```bash
# Use AMD64 emulation profile
nextflow run pipeline.nf -profile docker,emulate_amd64
```

Alternatively, use conda/mamba:

```bash
nextflow run pipeline.nf -profile conda
```

**3. Test on Both Platforms:**

```bash
# Test AMD64 emulation
nextflow run pipeline.nf -profile docker,emulate_amd64 -with-docker

# Test native (if available)
nextflow run pipeline.nf -profile docker,arm64 -with-docker
```

**4. Use Wave for Automatic Platform Handling:**

```groovy
// Wave automatically handles platform conversion
profiles {
    arm64 {
        wave.enabled = true
        wave.strategy = 'conda,container'
    }
}
```

### Summary for macOS ARM64 Users

**Recommended Approach:**

1. **For Compatibility**: Use `-profile docker,emulate_amd64` (works with all images, slower)
2. **For Performance**: Use `-profile conda` or `-profile mamba` (native, faster)
3. **For Advanced**: Use `-profile docker,arm64` with Wave (requires setup)

**Quick Start:**

```bash
# Most compatible (recommended for first-time users)
nextflow run pipeline.nf -profile docker,emulate_amd64

# Faster alternative (if tools available in conda)
nextflow run pipeline.nf -profile conda

# Native ARM64 (if Wave configured)
nextflow run pipeline.nf -profile docker,arm64
```

---

## Building Cross-Platform Images

### Overview

Cross-platform images support multiple architectures (amd64, arm64, etc.), enabling pipelines to run on different hardware, including macOS ARM64 (Apple Silicon).

### Docker Buildx for Multi-Platform

**Setup Buildx:**

```bash
# Create and use buildx builder
docker buildx create --name multiarch --use

# Inspect platforms
docker buildx inspect --bootstrap
```

**Build Multi-Platform Image:**

```bash
# Build for multiple platforms
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag quay.io/organization/tool_name:version \
    --push \
    .

# Build and load for local use (single platform)
docker buildx build \
    --platform linux/amd64 \
    --tag tool_name:version \
    --load \
    .
```

### Dockerfile for Cross-Platform

**Platform-Aware Dockerfile:**

```dockerfile
# Use platform-specific base images
FROM --platform=$BUILDPLATFORM python:3.9-slim as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Install platform-specific dependencies
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        apt-get update && apt-get install -y arm64-specific-package; \
    else \
        apt-get update && apt-get install -y amd64-specific-package; \
    fi

# Build tool (should handle cross-compilation)
WORKDIR /build
COPY . .
RUN python setup.py install

# Runtime stage
FROM --platform=$TARGETPLATFORM python:3.9-slim

COPY --from=builder /usr/local /usr/local

WORKDIR /data
ENTRYPOINT ["tool"]
```

**Build Script:**

```bash
#!/bin/bash
# build-multiarch.sh

set -e

IMAGE="quay.io/organization/tool_name"
VERSION="1.2.3"

# Build for multiple platforms
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag ${IMAGE}:${VERSION} \
    --tag ${IMAGE}:latest \
    --push \
    .

# Verify
docker buildx imagetools inspect ${IMAGE}:${VERSION}
```

### Testing Cross-Platform Images

**Test on Different Platforms:**

```bash
# Test amd64 image
docker run --rm --platform linux/amd64 tool_name:version tool --version

# Test arm64 image (on ARM machine or emulator)
docker run --rm --platform linux/arm64 tool_name:version tool --version

# Use QEMU for emulation (if needed)
docker run --rm --platform linux/arm64 --privileged tool_name:version tool --version
```

### CI/CD for Multi-Platform Builds

**GitHub Actions Example:**

```yaml
name: Build Multi-Platform Docker Image

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Quay.io
        uses: docker/login-action@v2
        with:
          registry: quay.io
          username: ${{ secrets.QUAY_USERNAME }}
          password: ${{ secrets.QUAY_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            quay.io/organization/tool_name:${{ github.ref_name }}
            quay.io/organization/tool_name:latest
```

---

## Container Configuration in Nextflow

### Profile Configuration

**In `nextflow.config`:**

```groovy
profiles {
    // Conda profile
    conda {
        conda.enabled = true
        conda.useMamba = true
        conda.cacheDir = "${workDir}/conda"
    }
    
    // Mamba profile
    mamba {
        conda.enabled = true
        conda.useMamba = true
        conda.cacheDir = "${workDir}/mamba"
    }
    
    // Docker profile
    docker {
        docker.enabled = true
        docker.runOptions = '-u $(id -u):$(id -g)'
    }
    
    // Docker profile with AMD64 emulation (for macOS ARM64)
    docker_amd64 {
        docker.enabled = true
        docker.runOptions = '-u $(id -u):$(id -g) --platform=linux/amd64'
    }
    
    // Singularity profile
    singularity {
        singularity.enabled = true
        singularity.autoMounts = true
        singularity.cacheDir = "${workDir}/singularity"
    }
    
    // Podman profile
    podman {
        podman.enabled = true
    }
}
```

### Process-Level Configuration

**In `modules.config`:**

```groovy
process {
    // Default container for all processes
    container = 'quay.io/biocontainers/base:latest'
    
    // Process-specific containers
    withName: 'TOOL1' {
        container = 'quay.io/biocontainers/tool1:1.0.0'
    }
    
    withName: 'TOOL2' {
        container = 'quay.io/biocontainers/tool2:2.0.0'
    }
    
    // Conditional container based on profile
    withName: 'TOOL3' {
        container = { workflow.containerEngine == 'singularity' ?
            'docker://quay.io/biocontainers/tool3:3.0.0' :
            'quay.io/biocontainers/tool3:3.0.0' }
    }
}
```

### Module-Level Configuration

**In module `main.nf`:**

```groovy
process TOOL {
    // Container declaration
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://quay.io/biocontainers/tool:1.2.3--build' :
        'quay.io/biocontainers/tool:1.2.3--build' }"
    
    // Conda environment (alternative to container)
    conda "${moduleDir}/environment.yml"
    
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    """
    tool --input ${input_file} --output ${output_file}
    """
}
```

### Handling Unavailable Containers

**Check and Provide Alternatives:**

```groovy
process TOOL {
    // Try Docker first, fallback to conda
    container = { 
        def dockerImage = 'quay.io/biocontainers/tool:1.2.3'
        // Check if image exists, use conda if not
        try {
            // Docker image available
            return dockerImage
        } catch (Exception e) {
            // Use conda instead
            return null
        }
    }
    
    conda = { container == null ? "${moduleDir}/environment.yml" : null }
    
    // ... rest of process
}
```

### Checking Docker Image Availability

**1. Check Image Availability in Nextflow (Groovy):**

```groovy
// Function to check if Docker image is available
def checkDockerImage(String image) {
    def proc = "docker manifest inspect ${image}".execute()
    proc.waitFor()
    return proc.exitValue() == 0
}

// Usage in process
process TOOL {
    container = { 
        def dockerImage = 'quay.io/biocontainers/tool:1.2.3'
        if (checkDockerImage(dockerImage)) {
            return dockerImage
        } else {
            return null  // Fallback to conda
        }
    }
    
    conda = { container == null ? "${moduleDir}/environment.yml" : null }
    
    // ... rest of process
}
```

**2. Check Image Availability with Platform Support:**

```bash
#!/bin/bash
# check_image_platform.sh - Check image availability for specific platform

IMAGE="${1:-quay.io/biocontainers/tool:1.2.3}"
PLATFORM="${2:-linux/amd64}"

echo "Checking ${IMAGE} for platform ${PLATFORM}"

# Check manifest
MANIFEST=$(docker manifest inspect "${IMAGE}" 2>/dev/null)

if [ $? -eq 0 ]; then
    # Check if platform is supported
    if echo "${MANIFEST}" | jq -e ".manifests[] | select(.platform.architecture == \"${PLATFORM##*/}\" and .platform.os == \"${PLATFORM%%/*}\")" > /dev/null 2>&1; then
        echo "✅ Image available for ${PLATFORM}"
    else
        echo "❌ Image not available for ${PLATFORM}"
        echo "Available platforms:"
        echo "${MANIFEST}" | jq -r '.manifests[] | "\(.platform.os)/\(.platform.architecture)"'
    fi
else
    echo "❌ Image not found"
    exit 1
fi
```

**3. Batch Check Multiple Images:**

```bash
#!/bin/bash
# check_images.sh - Check availability of multiple images

IMAGES=(
    "quay.io/biocontainers/tool1:1.0.0"
    "quay.io/biocontainers/tool2:2.0.0"
    "quay.io/biocontainers/tool3:3.0.0"
)

for IMAGE in "${IMAGES[@]}"; do
    if docker manifest inspect "${IMAGE}" > /dev/null 2>&1; then
        echo "✅ ${IMAGE}"
    else
        echo "❌ ${IMAGE}"
    fi
done
```

**4. Check Image Tags (List Available Versions):**

```bash
# Docker Hub (requires API)
curl -s "https://hub.docker.com/v2/repositories/username/tool/tags?page_size=100" | \
    jq -r '.results[].name'

# Quay.io
curl -s "https://quay.io/api/v1/repository/biocontainers/tool/tag/" | \
    jq -r '.tags[].name'

# Using skopeo
skopeo list-tags docker://quay.io/biocontainers/tool | \
    jq -r '.Tags[]'
```

**5. Verify Image Before Using in Nextflow:**

```groovy
// In nextflow.config or workflow script
def verifyImages() {
    def images = [
        'quay.io/biocontainers/tool1:1.0.0',
        'quay.io/biocontainers/tool2:2.0.0'
    ]
    
    images.each { image ->
        def proc = "docker manifest inspect ${image}".execute()
        proc.waitFor()
        if (proc.exitValue() != 0) {
            log.warn "⚠️  Image not available: ${image}"
        } else {
            log.info "✅ Image available: ${image}"
        }
    }
}

// Call at workflow start
workflow {
    verifyImages()
    // ... rest of workflow
}
```

### Common Issues and Solutions

#### Issue: "manifest unknown" or "not found"

```bash
# Problem: Image doesn't exist or tag is wrong
# Solution: Check tag spelling and registry

# List available tags
skopeo list-tags docker://quay.io/biocontainers/tool

# Or use registry API
curl -s "https://quay.io/api/v1/repository/biocontainers/tool/tag/" | \
    jq -r '.tags[].name' | grep "1.2"
```

#### Issue: "unauthorized" or "authentication required"

```bash
# Problem: Private registry requires authentication
# Solution: Login first

docker login quay.io
docker manifest inspect quay.io/organization/tool:version
```

#### Issue: "platform not supported"

```bash
# Problem: Image doesn't support your platform
# Solution: Check available platforms

docker manifest inspect quay.io/biocontainers/tool:1.2.3 | \
    jq '.manifests[].platform'

# Use platform emulation if needed
docker pull --platform linux/amd64 quay.io/biocontainers/tool:1.2.3
```

### Best Practices

**✅ Do:**

- Check image availability before committing to pipeline
- Verify platform support (especially for ARM64)
- Use `docker manifest inspect` to avoid downloading
- Document image sources and versions
- Test image pulls in CI/CD

**❌ Don't:**

- Assume images exist without checking
- Use `latest` tags without verification
- Ignore platform compatibility warnings
- Skip availability checks in automated workflows

### Quick Reference

```bash
# Quick check (most common)
docker manifest inspect IMAGE:TAG

# Check with platform
docker manifest inspect IMAGE:TAG --platform linux/amd64

# List all tags
skopeo list-tags docker://REGISTRY/IMAGE

# Check image details
docker buildx imagetools inspect IMAGE:TAG

# Test pull (downloads image)
docker pull IMAGE:TAG
```

---

## Best Practices

### 1. Container Image Selection

**✅ Do:**

- Use official/biocontainers images when available
- Pin specific versions (avoid `latest`)
- Use `quay.io/biocontainers/` prefix for biocontainers
- Verify image availability before committing

**❌ Don't:**

- Use `latest` tags in production
- Use untrusted or unverified images
- Mix container registries inconsistently

**Example:**

```groovy
// ✅ Good: Specific version from biocontainers
container 'quay.io/biocontainers/tool:1.2.3--build'

// ❌ Bad: Latest tag
container 'tool:latest'

// ❌ Bad: Unverified source
container 'random-user/tool:1.2.3'
```

### 2. Version Pinning

**Always Pin Versions:**

```groovy
// ✅ Good: Pinned version
container 'quay.io/biocontainers/tool:1.2.3--build123'

// ❌ Bad: Floating version
container 'quay.io/biocontainers/tool:1.2'

// ❌ Bad: No version
container 'quay.io/biocontainers/tool'
```

**In `environment.yml`:**

```yaml
# ✅ Good: Pinned versions
dependencies:
  - tool_name=1.2.3
  - python=3.9.16

# ❌ Bad: No versions
dependencies:
  - tool_name
  - python
```

### 3. Container Compatibility

**Handle Docker and Singularity:**

```groovy
// ✅ Good: Works with both Docker and Singularity
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'docker://quay.io/biocontainers/tool:1.2.3--build' :
    'quay.io/biocontainers/tool:1.2.3--build' }"

// ✅ Alternative: Let Nextflow handle conversion
container 'quay.io/biocontainers/tool:1.2.3--build'
// Nextflow automatically adds docker:// for Singularity
```

### 4. Cross-Platform Considerations

**Build for Target Platforms:**

```dockerfile
# ✅ Good: Multi-platform Dockerfile
FROM --platform=$TARGETPLATFORM python:3.9-slim

# ❌ Bad: Platform-specific assumptions
FROM python:3.9-slim  # May not work on ARM
```

**Test on Target Platforms:**

```bash
# Test on amd64
docker run --rm --platform linux/amd64 tool:version tool --version

# Test on arm64
docker run --rm --platform linux/arm64 tool:version tool --version
```

### 5. Container Size Optimization

**Use Multi-Stage Builds:**

```dockerfile
# ✅ Good: Multi-stage build
FROM python:3.9-slim as builder
# ... build steps ...

FROM python:3.9-slim
COPY --from=builder /usr/local /usr/local
# Final image is smaller

# ❌ Bad: Single stage with build tools
FROM python:3.9-slim
RUN apt-get install -y build-essential gcc g++  # Large image
# ... build and keep build tools ...
```

**Clean Up in Same Layer:**

```dockerfile
# ✅ Good: Clean up in same RUN
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ❌ Bad: Separate RUN commands
RUN apt-get update
RUN apt-get install -y package
RUN apt-get clean
```

### 6. Security Best Practices

**Use Non-Root User:**

```dockerfile
# ✅ Good: Non-root user
RUN useradd -m -u 1000 user
USER user
WORKDIR /home/user

# ❌ Bad: Run as root
# Defaults to root
```

**Scan Images for Vulnerabilities:**

```bash
# Use tools like Trivy, Snyk, or Docker Scout
trivy image quay.io/biocontainers/tool:1.2.3
```

**Minimize Attack Surface:**

```dockerfile
# ✅ Good: Minimal base image
FROM python:3.9-slim

# ❌ Bad: Full OS image
FROM ubuntu:latest
```

### 7. Caching and Performance

**Leverage Docker Layer Caching:**

```dockerfile
# ✅ Good: Dependencies first (cached)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Then application code (changes frequently)
COPY app/ /app/

# ❌ Bad: Everything together
COPY . .
RUN pip install -r requirements.txt
```

**Use BuildKit Cache:**

```bash
# ✅ Good: Use cache mounts
docker buildx build --cache-from type=local,src=/tmp/.buildx-cache .
```

### 8. Documentation

**Document Container Requirements:**

```groovy
// In module main.nf
/*
 * TOOL - Process description
 *
 * Container: quay.io/biocontainers/tool:1.2.3--build
 * Alternative: Use conda environment.yml if container unavailable
 */
process TOOL {
    // ...
}
```

**Document Build Process:**

```markdown
## Building Container

```bash
docker build -t tool:1.2.3 .
docker tag tool:1.2.3 quay.io/organization/tool:1.2.3
docker push quay.io/organization/tool:1.2.3
```

For multi-platform:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t tool:1.2.3 --push .
```

---

## Troubleshooting

### Common Issues

**1. Container Not Found:**

```groovy
// Check image availability
// Solution: Verify image exists and is accessible
container 'quay.io/biocontainers/tool:1.2.3--build'  // Verify this exists
```

**2. Platform Mismatch:**

```bash
# Error: image platform mismatch
# Solution: Build for correct platform or use multi-platform image
docker buildx build --platform linux/amd64 -t tool:version .
```

**3. Permission Issues:**

```groovy
// Docker: Run as current user
docker {
    runOptions = '-u $(id -u):$(id -g)'
}

// Singularity: Usually handles permissions automatically
```

**4. Conda Environment Creation Fails:**

```yaml
# Check for dependency conflicts
# Solution: Pin compatible versions
dependencies:
  - tool_name=1.2.3
  - python=3.9  # Ensure compatibility
```

**5. Cross-Platform Build Fails:**

```dockerfile
# Use platform-aware base images
FROM --platform=$TARGETPLATFORM python:3.9-slim

# Avoid platform-specific binaries
# Use interpreted languages or cross-compile
```

### Debugging Commands

**Docker:**

```bash
# Inspect image
docker inspect quay.io/biocontainers/tool:1.2.3

# Check image platform
docker buildx imagetools inspect quay.io/biocontainers/tool:1.2.3

# Test container
docker run --rm quay.io/biocontainers/tool:1.2.3 tool --version

# Check logs
docker logs <container_id>
```

**Singularity:**

```bash
# Inspect image
singularity inspect tool.sif

# Test container
singularity exec tool.sif tool --version

# Shell into container
singularity shell tool.sif
```

**Conda:**

```bash
# List environments
conda env list

# Activate and test
conda activate tool_environment
tool --version

# Check package versions
conda list
```

---

## Summary Checklist

### For Module Developers

- [ ] Choose appropriate containerization (Docker/Singularity vs Conda)
- [ ] Pin container/image versions
- [ ] Use biocontainers when available
- [ ] Handle both Docker and Singularity formats
- [ ] Document container requirements
- [ ] Test on target platforms
- [ ] Provide fallback to conda if container unavailable

### For Image Builders

- [ ] Use multi-stage builds for smaller images
- [ ] Build for multiple platforms (amd64, arm64)
- [ ] Pin base image versions
- [ ] Minimize layers and clean up
- [ ] Use non-root user when possible
- [ ] Scan for vulnerabilities
- [ ] Document build process
- [ ] Tag images appropriately

### For Pipeline Users

- [ ] Choose appropriate profile (`-profile docker`, `-profile conda`, etc.)
- [ ] Ensure container engine is installed and running
- [ ] Check image availability before running
- [ ] Use `--with-conda` or `--with-docker` flags if needed
- [ ] Monitor container pull/build times
- [ ] Verify platform compatibility

---

## References

- [Nextflow Container Documentation](https://www.nextflow.io/docs/latest/container.html)
- [Docker Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/)
- [Biocontainers](https://biocontainers.pro/)
- [Conda Documentation](https://docs.conda.io/)
- [Mamba Documentation](https://mamba.readthedocs.io/)
- [Singularity Documentation](https://docs.sylabs.io/)
- [Apptainer Documentation](https://apptainer.org/docs/)
- [Docker Buildx Documentation](https://docs.docker.com/build/buildx/)
- [Quay.io Documentation](https://docs.quay.io/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- Current pipeline examples: `modules/**/main.nf`, `nextflow.config`
- Related documentation: [CONFIGURATION_AND_TESTING_BEST_PRACTICES.md](CONFIGURATION_AND_TESTING_BEST_PRACTICES.md)
