#!/bin/bash
set -eux

# Set staging directory
STAGING_DIR="${STAGING_DIR:-$(pwd)/shadowsocks-rust-server}"
echo "STAGING_DIR set to: $STAGING_DIR"
mkdir -p "$STAGING_DIR/usr/bin" "$STAGING_DIR/script"

# Get version from GITHUB_REF_NAME, removing 'v' prefix if present
VERSION="${GITHUB_REF_NAME#v}"
echo "Building shadowsocks-rust version: $VERSION"

# Clone shadowsocks-rust
git clone https://github.com/shadowsocks/shadowsocks-rust
cd shadowsocks-rust
git checkout "v$VERSION"

# Build with musl target
RUSTFLAGS="-C target-feature=-crt-static -C link-self-contained=yes" \
cargo build --target x86_64-unknown-linux-musl --release

# Stage the binary
cp target/x86_64-unknown-linux-musl/release/ssserver "$STAGING_DIR/usr/bin/"
strip "$STAGING_DIR/usr/bin/ssserver"

# Stage script files (assuming they exist in the repo or need to be copied)
cp script/shadowsocks-rust.service "$STAGING_DIR/script/" || echo "Service file not found"
cp script/shadowsocks-rust-server@.service "$STAGING_DIR/script/" || echo "Template service file not found"
cp script/shadowsocks-rust.init "$STAGING_DIR/script/" || echo "Init script not found"
cp script/shadowsocks-rust.default "$STAGING_DIR/script/" || echo "Default file not found"
cp script/shadowsocks-rust.postinst "$STAGING_DIR/script/" || echo "Postinst script not found"

echo "Build and staging complete. Files staged at: $STAGING_DIR"
