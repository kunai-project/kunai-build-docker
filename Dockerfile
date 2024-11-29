# Use the official Debian base image
FROM debian:latest

# Install necessary build tools and libraries for Rust
RUN apt-get update && \
    apt-get install -y \
    curl \
    gcc \
    make \
    clang \
    libbpf-dev \
    git \
    && apt-get clean

# Create a non-root user named 'rust' and switch to this user
RUN useradd -m rust
USER rust

# Install Rust using rustup (official toolchain installer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the working directory and adjust permissions
WORKDIR /home/rust

# Ensure cargo's bin directory is in the PATH for the rust user
ENV PATH="/home/rust/.cargo/bin:${PATH}"

RUN cargo install bpf-linker

# This is a placeholder; you can copy your project here later
# COPY . /home/rust/project

# Set the entrypoint to bash for interactive use
ENTRYPOINT ["/bin/bash"]

