#!/bin/bash

set -ex

# rm -rf libpng-1.6.37
# rm -f libpng-1.6.37.tar.gz
# wget https://udomain.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz
# tar xvf libpng-1.6.37.tar.gz libpng-1.6.37
# WORKING_DIR="$(dirname "$0")/libpng-1.6.37"

rm -rf libpng
git clone --depth 1 https://github.com/pnggroup/libpng.git
WORKING_DIR="$(dirname "$0")/libpng"

# check if working dir is all right
if [ ! -d "$WORKING_DIR" ]; then
    mkdir -p "$WORKING_DIR"
fi

cd "$WORKING_DIR"
WORKING_DIR=$(pwd)

XCODE_DIR=$(xcode-select -p)
IOS_PLATFORMDIR="${XCODE_DIR}"/Platforms/iPhoneOS.platform
IOS_SYSROOT="$IOS_PLATFORMDIR"/Developer/SDKs/iPhoneOS.sdk
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=14.0"

cmake -G Xcode -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DCMAKE_MACOSX_BUNDLE="${WORKING_DIR}"/../output \
    -DCMAKE_INSTALL_PREFIX="${WORKING_DIR}"/../output \
    -DPNG_ARM_NEON=on \
    -DCMAKE_OSX_SYSROOT="${IOS_SYSROOT}"

xcodebuild build \
    -project build/libpng.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
cmake -P cmake_install.cmake
