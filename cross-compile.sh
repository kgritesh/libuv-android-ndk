#!/bin/bash

set -e

cd ${WORKDIR}

curl -s -O  https://dist.libuv.org/dist/v1.18.0/libuv-v1.18.0.tar.gz -o libuv-v1.18.0.tar.gz
tar -xvzf libuv-v1.18.0.tar.gz
rm -rf libuv-v1.18.0.tar.gz
mv libuv-v1.18.0 libuv
LIBUV_DIR=`pwd`/libuv
BUILD_DIR=${WORKDIR}/build

echo "Downloaded libuv library"

OLD_PATH=$PATH
for ARCH in arm arm64 x86 x86_64; do
    echo -e "\n\nCreating shared library for ${ARCH}"
    export TOOLCHAIN_DIR=`pwd`/toolchain-${ARCH}
    export PATH=$OLD_PATH:${TOOLCHAIN_DIR}/bin

    ${ANDROID_NDK_HOME}/build/tools/make_standalone_toolchain.py --arch ${ARCH} --api 24 --install-dir ${TOOLCHAIN_DIR}  --stl=libc++
    extra_flags=""
    case ${ARCH:=arm} in
      arm)
          target_host=arm-linux-androideabi
          extra_flags="-march=armv7-a -mthumb -mfpu=neon -Wl,--fix-cortex-a8"
          ;;
      arm64)
          target_host=aarch64-linux-android
          extra_flags="-march=armv8-a"
          ;;
      mips)   target_host=mipsel-linux-android ;;
      mips64) target_host=mips64el-linux-android ;;
      x86)   target_host=i686-linux-android ;;
      x86_64)   target_host=x86_64-linux-android ;;
    esac

    echo "Target Host is ${target_host}"
    export AR=$target_host-ar
    export AS=$target_host-clang
    export CC=$target_host-clang
    export CXX=$target_host-clang++
    export LD=$target_host-ld
    export STRIP=$target_host-strip
    export CFLAGS="-fPIE -fPIC ${extra_flags}"
    export CXXFLAGS="-fPIE -fPIC ${extra_flags}"
    export LD_FLAGS="-pie -static-libstdc++"

    cd $LIBUV_DIR
    mkdir -p  ${BUILD_DIR}/${ARCH}
    ls
    sh autogen.sh
    ./configure --host="${target_host}" --prefix=${BUILD_DIR}/${ARCH}
    make
    make install
    echo "Done creating shared libraries for ${ARCH}. Cleaning artifacts..."
    make clean
    cd ..
done