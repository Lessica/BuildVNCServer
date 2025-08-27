#!/bin/bash

set -ex

mkdir -p output
if [ -z "$SIMULATOR" ]; then
    rm -rf Build-OpenSSL-cURL
    git clone --depth=1 https://github.com/XXTouchNG/Build-OpenSSL-cURL.git
    cd Build-OpenSSL-cURL
    ./build.sh
    cd -
    cd BuildJPEG
    ./build.sh
    cd -
    cd BuildLZO
    ./build.sh
    cd -
    cd BuildPNG
    ./build.sh
    cd -
    cd BuildSASL
    ./build.sh
    cd -
fi

rm -rf libvncserver
git clone --depth=1 https://github.com/LibVNC/libvncserver.git
WORKING_DIR="$(dirname "$0")/libvncserver"

if [ ! -d "$WORKING_DIR" ]; then
    mkdir -p "$WORKING_DIR"
fi

cd "$WORKING_DIR"
WORKING_DIR=$(pwd)
patch -s -p0 < ../libvncserver.patch

git clean -fdx

if [ -n "$SIMULATOR" ]; then
    cmake -G Xcode -B build \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX="${WORKING_DIR}/../output" \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
        -DWITH_EXAMPLES=OFF \
        -DWITH_TESTS=OFF \
        -DWITH_SDL=OFF \
        -DWITH_GTK=OFF \
        -DWITH_GNUTLS=OFF \
        -DWITH_SYSTEMD=OFF \
        -DWITH_FFMPEG=OFF \
        -DWITH_LZO=OFF \
        -DWITH_JPEG=OFF \
        -DWITH_PNG=OFF \
        -DWITH_OPENSSL=OFF \
        -DWITH_SASL=OFF
else
    cmake -G Xcode -B build \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX="${WORKING_DIR}/../output" \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
        -DWITH_EXAMPLES=OFF \
        -DWITH_TESTS=OFF \
        -DWITH_SDL=OFF \
        -DWITH_GTK=OFF \
        -DWITH_GNUTLS=OFF \
        -DWITH_SYSTEMD=OFF \
        -DWITH_FFMPEG=OFF \
        -DLZO_LIBRARIES="$(realpath ../BuildLZO/output/lib/liblzo2.a)" \
        -DLZO_INCLUDE_DIR="$(realpath ../BuildLZO/output/include)" \
        -DJPEG_LIBRARY="$(realpath ../BuildJPEG/output/lib/libturbojpeg.a)" \
        -DJPEG_INCLUDE_DIR="$(realpath ../BuildJPEG/output/include)" \
        -DPNG_LIBRARY="$(realpath ../BuildPNG/output/lib/libpng16.a)" \
        -DPNG_PNG_INCLUDE_DIR="$(realpath ../BuildPNG/output/include)" \
        -DOPENSSL_LIBRARIES="$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib)" \
        -DOPENSSL_CRYPTO_LIBRARY="$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib/libcrypto.a)" \
        -DOPENSSL_SSL_LIBRARY="$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib/libssl.a)" \
        -DOPENSSL_INCLUDE_DIR="$(realpath ../Build-OpenSSL-cURL/openssl/iOS/include)" \
        -DLIBSASL2_LIBRARIES="$(realpath ../BuildSASL/output/lib/libsasl2.a)" \
        -DSASL2_INCLUDE_DIR="$(realpath ../BuildSASL/output/include)"
fi

cd build
patch include/rfb/rfbconfig.h -s -p0 < ../../libvncserver-build.patch
cd -

PLATFORM_NAME="iOS"
if [ -n "$SIMULATOR" ]; then
    PLATFORM_NAME="iOS Simulator"
fi

xcodebuild clean build \
    -project build/libvncserver.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination "generic/platform=${PLATFORM_NAME}" \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
if [ -n "$SIMULATOR" ]; then
    ln -s Release-iphonesimulator Release
    export PLATFORM_NAME="iphonesimulator"
    export EFFECTIVE_PLATFORM_NAME="-iphonesimulator"
    cmake -DCMAKE_INSTALL_PREFIX="$(realpath ../../output)" \
        -P cmake_install.cmake
else
    ln -s Release-iphoneos Release
    cmake -DCMAKE_INSTALL_PREFIX="$(realpath ../../output)" \
        -P cmake_install.cmake
fi

cd "$WORKING_DIR/.."
mkdir -p dist
mkdir -p dist/lib
mkdir -p dist/include
if [ -z "$SIMULATOR" ]; then
    lipo -thin arm64 Build-OpenSSL-cURL/openssl/iOS/lib/libcrypto.a -output dist/lib/libcrypto.a
    lipo -thin arm64 Build-OpenSSL-cURL/openssl/iOS/lib/libssl.a -output dist/lib/libssl.a
    cp -r Build-OpenSSL-cURL/openssl/iOS/include/* dist/include
    cp BuildJPEG/output/lib/libjpeg.a dist/lib/libjpeg.a
    cp BuildJPEG/output/lib/libturbojpeg.a dist/lib/libturbojpeg.a
    cp -r BuildJPEG/output/include/* dist/include
    cp BuildLZO/output/lib/liblzo2.a dist/lib/liblzo2.a
    cp -r BuildLZO/output/include/* dist/include
    cp BuildPNG/output/lib/libpng16.a dist/lib/libpng16.a
    cp BuildPNG/output/lib/libpng16.a dist/lib/libpng.a
    cp -r BuildPNG/output/include/* dist/include
    cp BuildSASL/output/lib/libsasl2.a dist/lib/libsasl2.a
    cp -r BuildSASL/output/include/* dist/include
fi
cp output/lib/libvncserver.a dist/lib/libvncserver.a
cp output/lib/libvncclient.a dist/lib/libvncclient.a
cp -r output/include/* dist/include
