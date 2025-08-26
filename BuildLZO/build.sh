#!/bin/bash

set -ex

rm -rf lzo-2.10
rm lzo-2.10.tar.gz
wget https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
tar xvf lzo-2.10.tar.gz lzo-2.10
WORKING_DIR="$(dirname "$0")/lzo-2.10"

# check if working dir is all right
if [ ! -d "$WORKING_DIR" ]; then
    mkdir -p "$WORKING_DIR"
fi

cd "$WORKING_DIR"
WORKING_DIR=$(pwd)

XCODE_DIR=$(xcode-select -p)
IOS_PLATFORMDIR="${XCODE_DIR}"/Platforms/iPhoneOS.platform
IOS_SYSROOT="${IOS_PLATFORMDIR}"/Developer/SDKs/iPhoneOS.sdk
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=14.0"

cmake -G Xcode -B build \
    -DCMAKE_INSTALL_PREFIX="${WORKING_DIR}"/../output \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
    -DCMAKE_OSX_SYSROOT="${IOS_SYSROOT}"

xcodebuild build \
    -project build/lzo.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
cmake -P cmake_install.cmake
