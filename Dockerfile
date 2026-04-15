# Use the official Debian base image
FROM rust:latest


# Install necessary build tools and libraries for Rust
RUN <<EOF
set -e

dpkg --add-architecture arm64
apt update
apt install -y git clang libbpf-dev lld crossbuild-essential-arm64 musl-tools:arm64
cargo install bpf-linker

rustup toolchain install nightly-x86_64-unknown-linux-gnu
rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu
EOF

# Clone kunai in /tmp
RUN git clone https://github.com/kunai-project/kunai.git /tmp/kunai

# Install Rust using rustup (official toolchain installer)
RUN <<EOF
CHANNEL=$(cat /tmp/kunai/rust-toolchain.toml | grep channel | cut -d '"' -f 2)
rustup toolchain install $CHANNEL-x86_64-unknown-linux-gnu
EOF

# Install rust targets
RUN <<EOF
set -e
rustup target add x86_64-unknown-linux-gnu
rustup target add x86_64-unknown-linux-musl

rustup target add aarch64-unknown-linux-gnu
rustup target add aarch64-unknown-linux-musl
EOF

# Install rust components just to prevent
# component download every time
RUN <<EOF
set -e
rustup component add clippy
rustup component add rust-src
EOF

# Remove tmp kunai code
RUN rm -rf /tmp/kunai
