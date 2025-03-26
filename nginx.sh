#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Define dependency versions
VER_NGINX="1.27.4"
VER_LIBERSSL="4.0.0"
VER_ZLIB="1.3.1"
VER_PCRE="10.45"
VER_FANCYINDEX="0.5.2"

# Define build dependencies
PKG_BUILD=(
    curl
    build-base
    linux-headers
    perl
)

# Set staging directory for installation
STAGING_DIR="${STAGING_DIR:-/tmp/staging}"

# Install build dependencies
apk --update add "${PKG_BUILD[@]}"

# Create staging directory
mkdir -p "$STAGING_DIR" || { echo "Failed to create STAGING_DIR: $STAGING_DIR"; exit 1; }

# Combine curl commands to download dependencies
cd /tmp || exit
curl -sSL "http://nginx.org/download/nginx-$VER_NGINX.tar.gz" -o "nginx-$VER_NGINX.tar.gz"
curl -sSL "http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$VER_LIBERSSL.tar.gz" -o "libressl-$VER_LIBERSSL.tar.gz"
curl -sSL "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VER_PCRE/pcre2-$VER_PCRE.tar.gz" -o "pcre2-$VER_PCRE.tar.gz"
curl -sSL "http://zlib.net/zlib-$VER_ZLIB.tar.gz" -o "zlib-$VER_ZLIB.tar.gz"
curl -sSL "https://github.com/aperezdc/ngx-fancyindex/releases/download/v$VER_FANCYINDEX/ngx-fancyindex-$VER_FANCYINDEX.tar.xz" -o "ngx-fancyindex-$VER_FANCYINDEX.tar.xz"

# Extract dependencies
tar xzf "nginx-$VER_NGINX.tar.gz"
tar xzf "libressl-$VER_LIBERSSL.tar.gz"
tar xzf "pcre2-$VER_PCRE.tar.gz"
tar xzf "zlib-$VER_ZLIB.tar.gz"
tar xf "ngx-fancyindex-$VER_FANCYINDEX.tar.xz"

# Build and install Nginx
cd "nginx-$VER_NGINX" || exit
./configure \
    --prefix=/usr \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --user=nobody \
    --group=nogroup \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_dav_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_secure_link_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_memcached_module \
    --with-openssl=../libressl-$VER_LIBERSSL \
    --with-zlib=../zlib-$VER_ZLIB \
    --with-pcre=../pcre2-$VER_PCRE \
    --add-module=../ngx-fancyindex-$VER_FANCYINDEX \
    --with-pcre-jit \
    --with-cc=x86_64-alpine-linux-musl-gcc \
    --with-cc-opt="-Os -fstack-protector-strong -DTCP_FASTOPEN=23" \
    --with-ld-opt="-Wl,-static -static -static-libgcc -no-pie"
make || { echo "Make failed"; exit 1; }
make install DESTDIR="$STAGING_DIR" || { echo "Make install failed"; exit 1; }

# Verify installation
ls -la "$STAGING_DIR/usr/sbin/nginx" || echo "Nginx binary not found in $STAGING_DIR/usr/sbin/nginx"

# Copy to container root for compatibility (optional)
cp "$STAGING_DIR/usr/sbin/nginx" /usr/sbin/nginx || echo "Copy to /usr/sbin/nginx failed"
