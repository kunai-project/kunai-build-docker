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

# Ensure cargo's bin directory is in the PATH for the rust user
ENV PATH="/home/rust/.cargo/bin:${PATH}"

# Install proper rustup channel
RUN git clone https://github.com/kunai-project/kunai.git /tmp/kunai && \
    CHANNEL=$(cat /tmp/kunai/rust-toolchain.toml | grep channel | cut -d '"' -f 2) && \
    rustup toolchain install $CHANNEL-x86_64-unknown-linux-gnu && \
    EBPF_CHANNEL=$(cat /tmp/kunai/kunai-ebpf/rust-toolchain.toml | grep channel | cut -d '"' -f 2) && \
    rustup toolchain install $EBPF_CHANNEL-x86_64-unknown-linux-gnu

# Set the working directory and adjust permissions
WORKDIR /home/rust

# Install bpf-linker
RUN cargo install bpf-linker

