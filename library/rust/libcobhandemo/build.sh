#!/bin/sh
set -e
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. ./.build-shared.sh

if [ "${DEBUG:-0}" -eq "1" ]; then
    BUILD_FLAGS="--features cobhan_debug"
    BUILD_DIR="debug"
else
    BUILD_FLAGS="--release"
    BUILD_DIR="release"
fi

if [ "${ALPINE:-0}" -eq "1" ]; then
    RUSTFLAGS="-C target-feature=-crt-static"
    export RUSTFLAGS
fi

# Build
cargo build --verbose ${BUILD_FLAGS} --target-dir target/

# Test
# TODO: Test libcobhandemo's functions using Python

# Copy Rust static library file
cp "target/${BUILD_DIR}/libcobhandemo.rlib" "output/libcobhandemo-${RLIB_SUFFIX}"

# Copy Rust dynamic library file
cp "target/${BUILD_DIR}/libcobhandemo${DYN_EXT}" "output/libcobhandemo-${DYN_SUFFIX}"

