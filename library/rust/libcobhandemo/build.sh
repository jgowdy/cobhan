#!/bin/sh
. "../../build-functions.sh"
mkdir -p output

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
cp "target/${BUILD_DIR}/libcobhandemo.rlib" "output/libcobhandemo-${RLIB_SUFFIX}"

# Copy Rust dynamic library file
cp "target/${BUILD_DIR}/libcobhandemo${DYN_EXT}" "output/libcobhandemo-${DYN_SUFFIX}"
