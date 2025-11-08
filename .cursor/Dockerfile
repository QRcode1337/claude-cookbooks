FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash ubuntu

# Set user and working directory
USER ubuntu
WORKDIR /home/ubuntu

# Upgrade pip and install common development tools
RUN pip install --user --upgrade pip setuptools wheel

# Install uv for faster package management (optional but recommended)
RUN pip install --user uv==0.5.0

# Set environment variables for Python
ENV PATH="/home/ubuntu/.local/bin:${PATH}"
ENV PYTHONUNBUFFERED=1

# Note: Dependencies will be installed when the code is cloned by the agent
# This Dockerfile only sets up the base development environment

