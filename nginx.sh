#!/usr/bin/env bash
# -*- coding: utf-8 -*-

export VER_NGINX="1.24.0"
export VER_LIBERSSL="3.9.1"
export VER_ZLIB="1.3.1"
export VER_PCRE="10.43"
export VER_FANCYINDEX="0.5.2"
export PKG_BUILD="curl build-base linux-headers perl"

apk --update add $PKG_BUILD
curl -sSL http://nginx.org/download/nginx-$VER_NGINX.tar.gz | tar xz -C /tmp
curl -sSL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$VER_LIBERSSL.tar.gz | tar xz -C /tmp
curl -sSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VER_PCRE/pcre2-$VER_PCRE.tar.gz | tar xz -C /tmp
curl -sSL http://zlib.net/zlib-$VER_ZLIB.tar.gz | tar xz -C /tmp
#curl -sSL https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.5.2/ngx-fancyindex-0.5.2.tar.xz | tar xf -C /tmp

cd /tmp/nginx-$VER_NGINX/
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
    make install
