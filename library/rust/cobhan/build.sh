#!/bin/sh
set -e
set -x
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. ./.build-shared.sh

if [ "${DEBUG:-0}" -eq "1" ]; then
    BUILD_FLAGS="--features cobhan_debug"
    BUILD_DIR="debug"
else
    BUILD_FLAGS="--release"
    BUILD_DIR="release"
fi

# Build
cargo build --verbose ${BUILD_FLAGS}

# Copy Rust static library file

cp "target/${BUILD_DIR}/libcobhan.rlib" "output/libcobhan-${RLIB_SUFFIX}"
