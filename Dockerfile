# Use the official Debian base image
FROM archlinux:latest

# !!! Mandatory !!!
RUN pacman-key --init

# Install necessary build tools and libraries for Rust
RUN <<EOF
set -e
pacman -Sy
pacman -S --noconfirm curl make clang libbpf git

# install for easy linking
pacman -S --noconfirm lld

# install x86_64 musl
pacman -S --noconfirm gcc musl

# install aarch musl
pacman -S --noconfirm aarch64-linux-gnu-gcc musl-aarch64
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
set -e
EBPF_CHANNEL=$(cat /tmp/kunai/kunai-ebpf/rust-toolchain.toml | grep channel | cut -d '"' -f 2)
EBPF_TOOLCHAIN="$EBPF_CHANNEL-x86_64-unknown-linux-gnu"
rustup toolchain install $EBPF_TOOLCHAIN
rustup component add rust-src --toolchain $EBPF_TOOLCHAIN
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

# Set the working directory and adjust permissions
WORKDIR /home/rust

# Install bpf-linker
RUN cargo install bpf-linker
