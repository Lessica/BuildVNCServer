#!/bin/zsh

set -ex

wget https://udomain.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz
tar xvf libpng-1.6.37.tar.gz libpng-1.6.37
WORKDING_DIR="$(dirname "$0")/libpng-1.6.37"

# check if working dir is all right
if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

IOS_PLATFORMDIR=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneOS.sdk)
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=13.0"

cmake -G Xcode -T buildsystem=1 -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DCMAKE_MACOSX_BUNDLE=${WORKDING_DIR}/../output \
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DPNG_ARM_NEON=on \
    -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT}

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
