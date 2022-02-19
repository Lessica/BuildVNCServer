#!/bin/zsh

set -ex

git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
WORKDING_DIR="$(dirname "$0")/libjpeg-turbo"

# check if working dir is all right
if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

git clean -fdx

IOS_PLATFORMDIR=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneOS.sdk)
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=13.0 -funwind-tables"

cat <<EOF >toolchain.cmake
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_OSX_DEPLOYMENT_TARGET 13.0)
set(CMAKE_C_COMPILER /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang)
EOF

cmake -G Xcode -B build \
    -DENABLE_SHARED=0 \
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
    -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT}

xcodebuild build \
    -project build/libjpeg-turbo.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
ln -s Release-iphoneos Release
cmake -P cmake_install.cmake
