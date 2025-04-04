#!/bin/bash
set -eux

# Set staging directory (same as repo directory for simplicity)
STAGING_DIR="$(pwd)/shadowsocks-rust-server"
echo "STAGING_DIR set to: $STAGING_DIR"
mkdir -p "$STAGING_DIR/usr/bin" "$STAGING_DIR/script" "$STAGING_DIR/etc/shadowsocks-rust"

# Use GITHUB_REF_NAME directly (e.g., v1.23.0)
VERSION="$GITHUB_REF_NAME"
echo "Requested shadowsocks-rust version: $VERSION"

# Clone shadowsocks-rust
git clone https://github.com/shadowsocks/shadowsocks-rust
cd shadowsocks-rust

# List available tags for debugging
echo "Available tags in shadowsocks-rust:"
git tag -l

# Checkout the exact version
git checkout "$VERSION"

# Build with musl target
RUSTFLAGS="-C target-feature=-crt-static -C link-self-contained=yes" \
cargo build --target x86_64-unknown-linux-musl --bin ssserver --release --no-default-features --features="server stream-cipher mimalloc multi-threaded"
cargo build --target x86_64-unknown-linux-musl --bin ssservice --release --no-default-features --features service

# Copy binaries to repo's shadowsocks-rust-server/usr/bin/
cp target/x86_64-unknown-linux-musl/release/ssserver "$STAGING_DIR/usr/bin/"
cp target/x86_64-unknown-linux-musl/release/ssservice "$STAGING_DIR/usr/bin/"
strip "$STAGING_DIR/usr/bin/ssserver"
strip "$STAGING_DIR/usr/bin/ssservice"

# Stage script files (assuming they exist in the repo)
cp script/shadowsocks-rust.service "$STAGING_DIR/script/" || echo "Service file not found"
cp script/shadowsocks-rust.init "$STAGING_DIR/script/" || echo "Init script not found"
cp script/shadowsocks-rust.default "$STAGING_DIR/script/" || echo "Default file not found"
cp script/shadowsocks-rust.postinst "$STAGING_DIR/script/" || echo "Postinst script not found"

# Stage etc/shadowsocks-rust (adjust if it's a file or directory in your repo)
cp -r etc/shadowsocks-rust/* "$STAGING_DIR/etc/shadowsocks-rust/" || echo "etc/shadowsocks-rust not found"

echo "Build and staging complete. Files staged at: $STAGING_DIR"
