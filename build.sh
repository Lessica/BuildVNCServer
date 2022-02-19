#!/bin/zsh

set -ex

git clone https://github.com/jasonacox/Build-OpenSSL-cURL.git
cd Build-OpenSSL-cURL
./build.sh
cd ..
cd BuildJPEG
./build.sh
cd ..
cd BuildLZO
./build.sh
cd ..
cd BuildPNG
./build.sh
cd ..
cd BuildSASL
./build.sh
cd ..

git clone https://github.com/LibVNC/libvncserver.git
WORKDING_DIR="$(dirname "$0")/libvncserver"

if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)
patch -s -p0 < ../libvncserver.patch

git clean -fdx

cmake -G Xcode -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DWITH_EXAMPLES=OFF \
    -DWITH_TESTS=PFF \
    -DLZO_LIBRARIES=$(realpath ../BuildLZO/output/lib) \
    -DLZO_INCLUDE_DIR=$(realpath ../BuildLZO/output/include) \
    -DJPEG_LIBRARY=$(realpath ../BuildJPEG/output/lib/libturbojpeg.a) \
    -DJPEG_INCLUDE_DIR=$(realpath ../BuildJPEG/output/include) \
    -DPNG_LIBRARY=$(realpath ../BuildPNG/output/lib/libpng16.a) \
    -DPNG_PNG_INCLUDE_DIR=$(realpath ../BuildPNG/output/include) \
    -DOPENSSL_LIBRARIES=$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib) \
    -DOPENSSL_CRYPTO_LIBRARY=$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib/libcrypto.a) \
    -DOPENSSL_SSL_LIBRARY==$(realpath ../Build-OpenSSL-cURL/openssl/iOS/lib/libssl.a) \
    -DOPENSSL_INCLUDE_DIR=$(realpath ../Build-OpenSSL-cURL/openssl/iOS/include) \
    -DLIBSASL2_LIBRARIES=$(realpath ../BuildSASL/output/lib) \
    -DSASL2_INCLUDE_DIR=$(realpath ../BuildSASL/output/include)

cd build
patch -s -p0 < ../../libvncserver-build.patch
cd ..

xcodebuild clean build \
    -project build/libvncserver.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
ln -s Release-iphoneos Release
cmake -P cmake_install.cmake

cd "$WORKDING_DIR/.."
mkdir dist
mkdir dist/lib
mkdir dist/include
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
cp output/lib/libvncserver.a dist/lib/libvncserver.a
cp output/lib/libvncclient.a dist/lib/libvncclient.a
cp -r output/include/* dist/include
