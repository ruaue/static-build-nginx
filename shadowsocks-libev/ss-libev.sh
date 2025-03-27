#!/usr/bin/env bash
# -*- coding: utf-8 -*-

export VER_SSLIBEV="3.3.5"
export VER_SIPOBFS="0.0.5"
export VER_MBEDTLS="2.28.0"
export VER_SODIUM="1.0.18"
export VER_PCRE="8.45"
export VER_EV="4.33"
export VER_CARES="1.19.0"
export PKG_BUILD="curl build-base linux-headers autoconf automake libtool"
export CFLAGS="-Os"
export LDFLAGS="-static -s"

apk --update upgrade
apk --update add $PKG_BUILD

#curl -sSL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$VER_SSLIBEV/shadowsocks-libev-$VER_SSLIBEV.tar.gz | tar xz -C /tmp
#curl -sSL https://github.com/shadowsocks/simple-obfs/archive/v$VER_SIPOBFS.tar.gz | tar xz -C /tmp
curl -sSL https://github.com/ARMmbed/mbedtls/archive/mbedtls-$VER_MBEDTLS.tar.gz | tar xz -C /tmp
curl -sSL https://download.libsodium.org/libsodium/releases/libsodium-$VER_SODIUM.tar.gz | tar xz -C /tmp
curl -sSL https://downloads.sourceforge.net/project/pcre/pcre/$VER_PCRE/pcre-$VER_PCRE.tar.gz | tar xz -C /tmp
curl -sSL http://dist.schmorp.de/libev/Attic/libev-$VER_EV.tar.gz | tar xz -C /tmp
curl -sSL  https://c-ares.haxx.se/download/c-ares-$VER_CARES.tar.gz | tar xz -C /tmp

cd /tmp/libsodium-$VER_SODIUM/
    ./configure \
        --prefix=/usr \
	--disable-ssp \
	--disable-shared
    make install

cd /tmp/mbedtls-mbedtls-$VER_MBEDTLS/
LDFLAGS="-static -no-pie" make DESTDIR=/usr install

cd /tmp/pcre-$VER_PCRE/
    ./configure \
        --prefix=/usr \
        --enable-jit \
        --enable-utf8 \
        --enable-unicode-properties \
        --disable-shared \
        --disable-cpp \
        --with-match-limit-recursion=8192
    make install

cd /tmp/libev-$VER_EV/
    ./configure \
        --prefix=/usr \
	--disable-shared
    make install

cd /tmp/c-ares-$VER_CARES/                                   
    ./buildconf                                           
    autoconf configure.ac                                 
    ./configure  \
	--prefix=/usr \
	--disable-shared
   make install

cd /tmp/shadowsocks-libev-$VER_SSLIBEV/
LIBS="-lpthread -lm" LDFLAGS="-Wl,-static -static -static-libgcc -no-pie"  ./configure --prefix=/usr --disable-documentation
    make install

#cd /tmp/simple-obfs-$VER_SIPOBFS/
#   ./autogen.sh
#LIBS="-lpthread -lm" LDFLAGS="-Wl,-static -static -static-libgcc -no-pie"  ./configure --prefix=/usr --disable-documentation
#    make install
