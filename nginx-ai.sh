#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Define dependency versions
VER_NGINX="1.24.0"
VER_LIBERSSL="3.9.1"
VER_ZLIB="1.3.1"
VER_PCRE="10.43"
VER_FANCYINDEX="0.5.2"

# Define build dependencies
PKG_BUILD=(
    curl
    build-base
    linux-headers
    perl
)

# Combine curl commands to download dependencies
curl -sSL http://nginx.org/download/nginx-$VER_NGINX.tar.gz \
     -o /tmp/nginx-$VER_NGINX.tar.gz
curl -sSL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$VER_LIBERSSL.tar.gz \
     -o /tmp/libressl-$VER_LIBERSSL.tar.gz
curl -sSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VER_PCRE/pcre2-$VER_PCRE.tar.gz \
     -o /tmp/pcre2-$VER_PCRE.tar.gz
curl -sSL http://zlib.net/zlib-$VER_ZLIB.tar.gz \
     -o /tmp/zlib-$VER_ZLIB.tar.gz
curl -sSL https://github.com/aperezdc/ngx-fancyindex/releases/download/v$VER_FANCYINDEX/ngx-fancyindex-$VER_FANCYINDEX.tar.xz \
     -o /tmp/ngx-fancyindex-$VER_FANCYINDEX.tar.xz

# Install build dependencies
apk --update add "${PKG_BUILD[@]}"

# Extract and build dependencies
cd /tmp || exit
tar xzf nginx-$VER_NGINX.tar.gz
tar xzf libressl-$VER_LIBERSSL.tar.gz
tar xzf pcre2-$VER_PCRE.tar.gz
tar xzf zlib-$VER_ZLIB.tar.gz
tar xf ngx-fancyindex-$VER_FANCYINDEX.tar.xz

# Build and install Nginx
cd nginx-$VER_NGINX || exit
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
make
make install

# Clean up
rm -rf /tmp/nginx-$VER_NGINX /tmp/libressl-$VER_LIBERSSL /tmp/pcre2-$VER_PCRE /tmp/zlib-$VER_ZLIB /tmp/ngx-fancyindex-$VER_FANCYINDEX
