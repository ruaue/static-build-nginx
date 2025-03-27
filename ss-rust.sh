#!/bin/bash
set -eux

# Set staging directory
STAGING_DIR="${STAGING_DIR:-$(pwd)/shadowsocks-rust-server}"
echo "STAGING_DIR set to: $STAGING_DIR"
mkdir -p "$STAGING_DIR/usr/bin" "$STAGING_DIR/script"

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
cargo build --target x86_64-unknown-linux-musl --release

# Stage the binaries
cp target/x86_64-unknown-linux-musl/release/ssserver "$STAGING_DIR/usr/bin/"
cp target/x86_64-unknown-linux-musl/release/ssservice "$STAGING_DIR/usr/bin/"
strip "$STAGING_DIR/usr/bin/ssserver"
strip "$STAGING_DIR/usr/bin/ssservice"

# Stage script files (assuming they exist in the repo or need to be copied)
cp script/shadowsocks-rust.service "$STAGING_DIR/script/" || echo "Service file not found"
cp script/shadowsocks-rust-server@.service "$STAGING_DIR/script/" || echo "Template service file not found"
cp script/shadowsocks-rust.init "$STAGING_DIR/script/" || echo "Init script not found"
cp script/shadowsocks-rust.default "$STAGING_DIR/script/" || echo "Default file not found"
cp script/shadowsocks-rust.postinst "$STAGING_DIR/script/" || echo "Postinst script not found"

echo "Build and staging complete. Files staged at: $STAGING_DIR"
