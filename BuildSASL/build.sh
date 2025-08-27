#!/bin/zsh

set -ex

rm -rf cyrus-sasl
mkdir -p output
git clone --depth=1 https://github.com/cyrusimap/cyrus-sasl.git # ac0c278817a082c625c496ec812318c019e0b96f
WORKING_DIR="$(dirname "$0")/cyrus-sasl"

if [ ! -d "$WORKING_DIR" ]; then
    mkdir -p "$WORKING_DIR"
fi

cd "$WORKING_DIR"
WORKING_DIR=$(pwd)

git clean -fdx

XCODE_DIR=$(xcode-select -p)
OUTPUT_PATH=$(realpath ../output)
export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=14.0 -isysroot ${XCODE_DIR}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
./autogen.sh --prefix="$OUTPUT_PATH" \
    --with-openssl="$(realpath ../../Build-OpenSSL-cURL/openssl/iOS)" \
    --host=aarch64-apple-darwin --with-staticsasl
make install DESTDIR="$(realpath ../output)" || true
cd ..

mv output/**/BuildSASL/output/* output
