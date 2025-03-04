# Use the official Debian base image
FROM debian:stable-slim

# Install necessary build tools and libraries for Rust
RUN <<EOF
apt-get update
apt-get install -y curl gcc make clang libbpf-dev git
apt-get clean
EOF

# Create a non-root user named 'rust' and switch to this user
RUN useradd -m rust
USER rust

# Clone kunai in /tmp
RUN git clone https://github.com/kunai-project/kunai.git /tmp/kunai

# Install Rust using rustup (official toolchain installer)
RUN <<EOF
CHANNEL=$(cat /tmp/kunai/rust-toolchain.toml | grep channel | cut -d '"' -f 2)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $CHANNEL-x86_64-unknown-linux-gnu
EOF

# Ensure cargo's bin directory is in the PATH for the rust user
ENV PATH="/home/rust/.cargo/bin:${PATH}"


# Install proper rustup channels and components
RUN <<EOF
EBPF_CHANNEL=$(cat /tmp/kunai/kunai-ebpf/rust-toolchain.toml | grep channel | cut -d '"' -f 2)
EBPF_TOOLCHAIN="$EBPF_CHANNEL-x86_64-unknown-linux-gnu"
rustup toolchain install $EBPF_TOOLCHAIN
rustup component add rust-src --toolchain $EBPF_TOOLCHAIN
EOF

# Remove tmp kunai code
RUN rm -rf /tmp/kunai

# Set the working directory and adjust permissions
WORKDIR /home/rust

# Install bpf-linker
RUN cargo install bpf-linker

