# BuildVNCServer

macOS cross-compiled `libvncserver` **static library** for iOS **arm64** platform.

*This build fixes CMake endian tests on iOS sdks, if you met `Protocol error: bad desktop size`* in `VNC Viewer`, this patch may help.

## Components

Base SDK: `iPhoneOS13.0.sdk`

- `libvncserver`: [libvncserver](https://github.com/LibVNC/libvncserver)
- `libjpeg-turbo`: [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)
- `libpng`: [libpng-1.6.37](http://www.libpng.org/pub/png/libpng.html)
- `lzo`: [lzo-2.10](https://www.oberhumer.com/opensource/lzo/)
- `openssl`: [Build-OpenSSL-cURL](https://github.com/jasonacox/Build-OpenSSL-cURL)

## Build Environments

```sh
$ uname -a
Darwin Kernel Version 21.3.0: Wed Jan  5 21:37:58 PST 2022; root:xnu-8019.80.24~20/RELEASE_ARM64_T6000 arm64 arm64 MacBookPro18,1 Darwin
```

```sh
$ cmake --version
cmake version 3.22.1

CMake suite maintained and supported by Kitware (kitware.com/cmake).
```

```sh
$ xcodebuild -version
Xcode 12.5.1
Build version 12E507
```

```sh
$ xcpretty --version
0.3.0
```

## Build

```sh
git clone https://github.com/Lessica/BuildVNCServer.git
cd BuildVNCServer
chmod +x build.sh
./build.sh
```

## Clean

```sh
git clean -fdx
```
