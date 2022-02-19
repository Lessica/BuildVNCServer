#!/bin/zsh

set -ex

git clone https://github.com/cyrusimap/cyrus-sasl.git
WORKDING_DIR="$(dirname "$0")/cyrus-sasl"

if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

git clean -fdx

OUTPUT_PATH=$(realpath ../output)
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=13.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
./autogen.sh --prefix="$OUTPUT_PATH" \
    --host=aarch64-apple-darwin --with-staticsasl
make install DESTDIR=$(realpath ../output)
cd ..

mv output/**/cyrus-sasl/build/* output
