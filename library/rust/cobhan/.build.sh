#!/bin/sh
set -e
if [ -e ./.build/.build-shared.sh ]; then
    . ./.build/.build-shared.sh
else
    echo '.build/build-shared.sh is missing'
    exit 255
fi

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
