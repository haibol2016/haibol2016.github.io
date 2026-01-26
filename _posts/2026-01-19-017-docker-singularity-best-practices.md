---
layout: post
title: "Best Practices for Creating Docker Images Compatible with Singularity"
date: 2026-01-19
categories: [bioinformatics, containers, docker, singularity, workflows]
tags: [docker, singularity, containers, containerization, HPC, reproducibility, best-practices, bioinformatics, workflows, apptainer]
author: Haibo Liu, PhD
toc: true
excerpt: "Comprehensive guide to creating Docker images that work seamlessly with Singularity/Apptainer, covering compatibility considerations, Dockerfile best practices, common pitfalls, and testing strategies for HPC environments."
---

## Introduction

---

Containerization has become essential for reproducible bioinformatics workflows. While **Docker** is widely used in development and cloud environments, **Singularity** (now **Apptainer**) is the preferred container runtime in HPC clusters due to security and performance requirements. Many workflows need to support both platforms, making it crucial to create Docker images that can be seamlessly converted and used with Singularity.

This guide provides **best practices for creating Docker images that are fully compatible with Singularity**, ensuring your containers work reliably across both Docker and HPC environments. We'll cover compatibility considerations, Dockerfile design patterns, common issues, and testing strategies.

### Why Singularity Compatibility Matters

**Singularity/Apptainer** is designed for HPC environments where:

- **No root access**: Users cannot run Docker daemon
- **Security**: Containers run as the user, not root
- **Performance**: Native performance with minimal overhead
- **File system integration**: Seamless access to host file systems

**Key Challenge**: While Singularity can pull Docker images directly using the `docker://` prefix, not all Docker images work correctly when converted. Understanding the differences and following best practices ensures your images work in both environments.

### Docker vs. Singularity: Key Differences

| Aspect | Docker | Singularity/Apptainer |
|--------|--------|----------------------|
| **User context** | Runs as root (by default) | Runs as the host user |
| **File permissions** | Root-owned files | User-owned files |
| **Volume mounts** | Explicit `-v` flag | Automatic bind mounts |
| **Environment variables** | Inherited from host | Merged with container |
| **Entrypoint/CMD** | Can be overridden | Can be overridden |
| **Network** | Isolated network | Uses host network |
| **Device access** | Limited | Full access to host devices |

---

## Core Principles for Singularity-Compatible Docker Images

### 1. Avoid Root-Only Operations

**Problem**: Docker images often create files as root, which causes permission issues in Singularity (where containers run as the user).

**Solution**: Use non-root users and proper file permissions.

```dockerfile
# ❌ Bad: Creates root-owned files
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y tool
RUN echo "data" > /data/output.txt

# ✅ Good: Use non-root user
FROM ubuntu:22.04

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install tools
RUN apt-get update && apt-get install -y tool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories with proper permissions
RUN mkdir -p /data && chown -R appuser:appuser /data

# Switch to non-root user
USER appuser
WORKDIR /data
```

**Best Practice**: Always create and use a non-root user for production images.

### 2. Use Absolute Paths for Executables

**Problem**: Relative paths and PATH-dependent execution can fail in Singularity.

**Solution**: Use absolute paths or ensure PATH is properly set.

```dockerfile
# ❌ Bad: Relative paths
RUN ./configure && make && make install

# ✅ Good: Absolute paths or explicit PATH
ENV PATH="/usr/local/bin:${PATH}"
RUN /usr/local/bin/configure && \
    make && \
    make install

# Or ensure tools are in standard locations
RUN ./configure --prefix=/usr/local && \
    make && \
    make install
```

### 3. Handle Environment Variables Correctly

**Problem**: Environment variables set in Dockerfiles may not persist or merge correctly in Singularity.

**Solution**: Use `ENV` for persistent variables and provide defaults.

```dockerfile
# ✅ Good: Explicit environment variables
ENV TOOL_VERSION=1.2.3
ENV PATH="/opt/tool/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/tool/lib:${LD_LIBRARY_PATH}"

# Make environment variables available at runtime
ENV TOOL_CONFIG="/opt/tool/config"
```

**Note**: Singularity will merge these with host environment variables, so avoid overriding critical system variables.

### 4. Avoid Hardcoded User IDs

**Problem**: Hardcoded UIDs/GIDs can conflict with host user IDs in Singularity.

**Solution**: Use symbolic user names or make UIDs configurable.

```dockerfile
# ❌ Bad: Hardcoded UID
RUN useradd -u 1000 appuser

# ✅ Good: Let system assign UID or use high-range UID
RUN useradd -r -u 9001 -g appuser appuser

# Or better: Use symbolic name (Singularity will map to host user)
RUN groupadd -r appuser && useradd -r -g appuser appuser
```

### 5. Design for Read-Only Containers

**Problem**: Some Docker images write to system directories, which may be read-only in Singularity.

**Solution**: Write to user-writable directories or use bind mounts.

```dockerfile
# ✅ Good: Write to user-writable locations
ENV HOME=/home/appuser
WORKDIR /home/appuser

# Create writable directories
RUN mkdir -p /home/appuser/{data,output,scratch} && \
    chown -R appuser:appuser /home/appuser

# Use /tmp for temporary files (usually writable in Singularity)
ENV TMPDIR=/tmp
```

---

## Dockerfile Best Practices

### Minimal Base Images

Start with minimal base images to reduce size and attack surface:

```dockerfile
# ✅ Good: Minimal base image
FROM python:3.9-slim

# ❌ Avoid: Full OS image
FROM ubuntu:22.04
```

**Recommended base images**:
- `python:3.9-slim` (Python applications)
- `debian:bullseye-slim` (General purpose)
- `alpine:latest` (Ultra-minimal, but may have compatibility issues)
- `biocontainers/base` (Bioinformatics-specific)

### Multi-Stage Builds

Use multi-stage builds to keep final images small:

```dockerfile
# Build stage
FROM python:3.9-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        make \
        && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.9-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Set up environment
ENV PATH="/home/appuser/.local/bin:${PATH}"
ENV PYTHONPATH="/home/appuser/.local/lib/python3.9/site-packages:${PYTHONPATH}"

# Switch to non-root user
USER appuser
WORKDIR /home/appuser

# Verify installation
RUN python -c "import tool; print(tool.__version__)"
```

### Layer Optimization

Combine related operations in single RUN commands to reduce layers:

```dockerfile
# ❌ Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y tool1
RUN apt-get install -y tool2
RUN apt-get clean

# ✅ Good: Single layer with cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tool1 \
        tool2 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Proper Entrypoint Design

Design entrypoints that work in both Docker and Singularity:

```dockerfile
# ✅ Good: Flexible entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tool"]

# entrypoint.sh content:
#!/bin/bash
set -euo pipefail

# Handle both direct tool execution and command passthrough
if [ "$#" -eq 0 ] || [ "$1" = "tool" ]; then
    exec /usr/local/bin/tool "${@:2}"
else
    exec "$@"
fi
```

### Version Pinning

Pin all versions for reproducibility:

```dockerfile
# ✅ Good: Pinned versions
FROM python:3.9.16-slim
ENV TOOL_VERSION=1.2.3

# ❌ Bad: Latest tags
FROM python:latest
ENV TOOL_VERSION=latest
```

---

## Common Issues and Solutions

### Issue 1: Permission Denied Errors

**Symptom**: Files created in Docker are owned by root, causing permission errors in Singularity.

**Solution**:

```dockerfile
# Create directories with proper ownership
RUN mkdir -p /data && \
    chown -R appuser:appuser /data

# Or use world-writable directories for shared data
RUN mkdir -p /shared && \
    chmod 777 /shared
```

**Runtime fix** (if you can't modify the image):

```bash
# In Singularity, bind mount to writable location
singularity exec --bind /host/data:/data image.sif tool --input /data/input
```

### Issue 2: Missing Libraries or Dependencies

**Symptom**: Tools fail with "library not found" errors in Singularity.

**Solution**: Ensure all dependencies are included and library paths are set:

```dockerfile
# Install all runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libc6 \
        libstdc++6 \
        libgcc-s1 \
        ca-certificates \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set library paths
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
```

### Issue 3: Environment Variable Conflicts

**Symptom**: Environment variables from host override container settings.

**Solution**: Use `SINGULARITYENV_` prefix or design for variable merging:

```dockerfile
# Set defaults that can be overridden
ENV TOOL_CONFIG="/opt/tool/default.conf"
ENV TOOL_DATA="/opt/tool/data"
```

**Runtime** (if needed):

```bash
# Override in Singularity
export SINGULARITYENV_TOOL_CONFIG=/host/path/config
singularity exec image.sif tool
```

### Issue 4: Network Access Issues

**Symptom**: Tools can't access network resources in Singularity.

**Solution**: Design for host network (Singularity's default):

```dockerfile
# Don't assume isolated network
# Use host-accessible URLs or provide configuration
ENV API_URL="http://localhost:8080"
```

**Note**: Singularity uses host network by default, which is usually fine but may differ from Docker's isolated network.

### Issue 5: Device Access

**Symptom**: Tools can't access GPUs or other devices.

**Solution**: Use `--nv` flag for NVIDIA GPUs or `--containall` for isolation:

```bash
# GPU access in Singularity
singularity exec --nv image.sif tool --gpu

# Device access
singularity exec --device /dev/device image.sif tool
```

---

## Complete Example: Bioinformatics Tool Container

Here's a complete example of a Singularity-compatible Docker image for a bioinformatics tool:

```dockerfile
# Multi-stage build for bioinformatics tool
FROM python:3.9.16-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        make \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        curl \
        && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Install tool from source
RUN curl -L https://github.com/org/tool/releases/download/v1.2.3/tool-1.2.3.tar.gz | \
    tar -xz && \
    cd tool-1.2.3 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install

# Runtime stage
FROM python:3.9.16-slim

# Metadata
LABEL maintainer="Your Name <email@example.com>"
LABEL version="1.2.3"
LABEL description="Bioinformatics tool container for variant analysis"

# Create non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser -u 9001 appuser && \
    mkdir -p /home/appuser/{data,output,scratch} && \
    chown -R appuser:appuser /home/appuser

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libc6 \
        libstdc++6 \
        zlib1g \
        libbz2-1.0 \
        liblzma5 \
        ca-certificates \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages and tool from builder
COPY --from=builder /root/.local /home/appuser/.local
COPY --from=builder /usr/local/bin/tool /usr/local/bin/tool
COPY --from=builder /usr/local/lib/libtool* /usr/local/lib/

# Set up environment
ENV PATH="/home/appuser/.local/bin:/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
ENV PYTHONPATH="/home/appuser/.local/lib/python3.9/site-packages:${PYTHONPATH}"
ENV HOME=/home/appuser
ENV TMPDIR=/tmp

# Create entrypoint script
RUN cat > /usr/local/bin/entrypoint.sh << 'EOF' && \
    chmod +x /usr/local/bin/entrypoint.sh
#!/bin/bash
set -euo pipefail

# Change to user's working directory if mounted
if [ -d "/home/appuser/data" ]; then
    cd /home/appuser/data
fi

# Execute command
if [ "$#" -eq 0 ]; then
    exec /usr/local/bin/tool --help
elif [ "$1" = "tool" ]; then
    exec /usr/local/bin/tool "${@:2}"
else
    exec "$@"
fi
EOF

# Switch to non-root user
USER appuser
WORKDIR /home/appuser

# Verify installation
RUN tool --version && \
    python -c "import tool; print('Tool Python module loaded')"

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tool"]
```

**Build and test**:

```bash
# Build Docker image
docker build -t tool:1.2.3 -f Dockerfile .

# Test in Docker
docker run --rm tool:1.2.3 tool --version

# Convert to Singularity
singularity build tool.sif docker://tool:1.2.3

# Test in Singularity
singularity exec tool.sif tool --version
```

---

## Testing Strategies

### 1. Test in Both Environments

Always test your Docker image in both Docker and Singularity:

```bash
#!/bin/bash
# test_container.sh

IMAGE="tool:1.2.3"
SIF="tool.sif"

echo "Testing Docker image..."
docker run --rm ${IMAGE} tool --version
docker run --rm ${IMAGE} tool --help

echo "Converting to Singularity..."
singularity build ${SIF} docker://${IMAGE}

echo "Testing Singularity image..."
singularity exec ${SIF} tool --version
singularity exec ${SIF} tool --help

echo "Testing with user context..."
singularity exec ${SIF} whoami
singularity exec ${SIF} id
```

### 2. Test File Permissions

Verify files can be created and written:

```bash
# Test file creation in Singularity
singularity exec tool.sif bash -c "touch /tmp/test.txt && ls -l /tmp/test.txt"

# Test in user directory
singularity exec --bind $(pwd):/data tool.sif bash -c "cd /data && touch test.txt && ls -l test.txt"
```

### 3. Test Environment Variables

Verify environment variables work correctly:

```bash
# Test environment variable inheritance
export TEST_VAR="host_value"
singularity exec --env TEST_VAR tool.sif bash -c "echo \$TEST_VAR"

# Test container environment variables
singularity exec tool.sif env | grep TOOL
```

### 4. Test Network Access

Verify network functionality:

```bash
# Test network access
singularity exec tool.sif curl -I https://www.example.com

# Test API access (if applicable)
singularity exec tool.sif tool --api-url https://api.example.com status
```

### 5. Test GPU Access (if applicable)

```bash
# Test NVIDIA GPU access
singularity exec --nv tool.sif nvidia-smi

# Test CUDA functionality
singularity exec --nv tool.sif tool --gpu --test
```

---

## Integration with Nextflow

### Module Configuration

In Nextflow modules, handle both Docker and Singularity:

```groovy
process TOOL {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://quay.io/biocontainers/tool:1.2.3--build' :
        'quay.io/biocontainers/tool:1.2.3--build' }"
    
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

### Custom Image Configuration

For custom images:

```groovy
process TOOL {
    container "${ workflow.containerEngine == 'singularity' ?
        'docker://docker.io/username/tool:1.2.3' :
        'docker.io/username/tool:1.2.3' }"
    
    // Ensure proper working directory
    cwd "${workDir}"
    
    input:
    path input_file
    
    output:
    path output_file
    
    script:
    """
    # Use absolute paths or ensure working directory is set
    tool --input ${input_file} --output ${output_file}
    """
}
```

---

## Checklist for Singularity-Compatible Docker Images

Use this checklist when creating Docker images for Singularity compatibility:

### Dockerfile Design

- [ ] **Non-root user**: Create and use a non-root user
- [ ] **Proper permissions**: Set correct file/directory permissions
- [ ] **Absolute paths**: Use absolute paths for executables and libraries
- [ ] **Environment variables**: Set ENV variables with defaults
- [ ] **Minimal base**: Use minimal base images (slim, alpine)
- [ ] **Layer optimization**: Combine RUN commands to reduce layers
- [ ] **Version pinning**: Pin all versions (base image, tools, dependencies)
- [ ] **Cleanup**: Remove build dependencies and cache in same layer

### Compatibility

- [ ] **No hardcoded UIDs**: Avoid hardcoded user/group IDs
- [ ] **Writable directories**: Create user-writable directories
- [ ] **Library paths**: Set LD_LIBRARY_PATH for custom libraries
- [ ] **Entrypoint flexibility**: Design entrypoint to handle both direct execution and command passthrough
- [ ] **Network assumptions**: Don't assume isolated network
- [ ] **Device access**: Document GPU/device requirements if applicable

### Testing

- [ ] **Docker test**: Test image in Docker environment
- [ ] **Singularity conversion**: Successfully convert to Singularity
- [ ] **Singularity execution**: Test tool execution in Singularity
- [ ] **File permissions**: Verify file creation/writing works
- [ ] **Environment variables**: Test variable inheritance and merging
- [ ] **Network access**: Verify network functionality
- [ ] **Nextflow integration**: Test with Nextflow workflows

### Documentation

- [ ] **README**: Document image contents and usage
- [ ] **Version tags**: Use semantic versioning for tags
- [ ] **Build instructions**: Provide build commands
- [ ] **Usage examples**: Include Docker and Singularity examples
- [ ] **Known issues**: Document any limitations or workarounds

---

## Advanced Topics

### Handling Conda Environments

If your tool uses Conda, ensure compatibility:

```dockerfile
FROM continuumio/miniconda3:4.12.0

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install conda packages
RUN conda install -y -c bioconda \
        tool=1.2.3 \
        dependency1=2.0.0 \
    && \
    conda clean -afy

# Set up environment
ENV PATH="/opt/conda/bin:${PATH}"

# Fix permissions
RUN chown -R appuser:appuser /opt/conda

USER appuser
```

### Handling R Packages

For R-based tools:

```dockerfile
FROM r-base:4.2.2

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install R packages as user
USER appuser
RUN R -e "install.packages(c('package1', 'package2'), repos='https://cloud.r-project.org')"

# Set R library path
ENV R_LIBS_USER="/home/appuser/R/x86_64-pc-linux-gnu-library/4.2"
```

### Multi-Architecture Support

Build for multiple architectures:

```bash
# Build for AMD64 and ARM64
docker buildx create --use
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t tool:1.2.3 \
    --push \
    -f Dockerfile .
```

**Note**: Test Singularity conversion for each architecture separately.

---

## Troubleshooting Guide

### Problem: "Permission denied" when writing files

**Solution**:
```dockerfile
# Ensure directories are writable
RUN mkdir -p /data && chmod 777 /data

# Or use user's home directory
ENV HOME=/home/appuser
WORKDIR /home/appuser
```

### Problem: "Command not found" in Singularity

**Solution**:
```dockerfile
# Use absolute paths
ENV PATH="/usr/local/bin:${PATH}"

# Verify in Dockerfile
RUN which tool && tool --version
```

### Problem: Library loading errors

**Solution**:
```dockerfile
# Set library paths
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# Include all required libraries
RUN ldd /usr/local/bin/tool
```

### Problem: Environment variables not working

**Solution**:
```dockerfile
# Use ENV for persistent variables
ENV TOOL_CONFIG="/opt/tool/config"

# Test in container
RUN echo $TOOL_CONFIG
```

---

## Summary

Creating Docker images that work seamlessly with Singularity requires attention to:

1. **User context**: Design for non-root execution
2. **File permissions**: Ensure writable directories
3. **Path handling**: Use absolute paths and proper PATH setup
4. **Environment variables**: Set defaults that can be overridden
5. **Testing**: Test in both Docker and Singularity environments

Following these best practices ensures your containers work reliably across both Docker and HPC environments, enabling reproducible workflows that can run anywhere.

---

## References

- [Singularity Documentation](https://docs.sylabs.io/)
- [Apptainer Documentation](https://apptainer.org/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Biocontainers Guidelines](https://biocontainers.pro/guidelines/)
- [Nextflow Container Documentation](https://www.nextflow.io/docs/latest/container.html)

