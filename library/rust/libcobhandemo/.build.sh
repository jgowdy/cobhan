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

if [ "${ALPINE:-0}" -eq "1" ]; then
    RUSTFLAGS="-C target-feature=-crt-static"
    export RUSTFLAGS
fi

# Build
echo "Compiling (Rust) ${BUILD_DIR}/libcobhandemo${DYN_EXT}"
cargo build --verbose ${BUILD_FLAGS} --target-dir target/

# Test Rust dynamic library file
count=0
while [ $count -lt 20 ]; do
    echo "Test iteration ${count}"
    python3 .test/consumer_console_app.py "target/${BUILD_DIR}/libcobhandemo${DYN_EXT}"
    if [ "$?" -eq "0" ]; then
        echo "Passed"
    else
        echo "Tests failed (Rust): libcobhandemo-${DYN_SUFFIX} Result: $?"
        exit 255
    fi
    count=$(expr ${count} + 1)
done

echo "Tests passed (Rust): libcobhandemo-${DYN_SUFFIX}"

# Copy Rust dynamic library file
cp "target/${BUILD_DIR}/libcobhandemo${DYN_EXT}" "output/libcobhandemo-${DYN_SUFFIX}"

# Copy Rust static library file
cp "target/${BUILD_DIR}/libcobhandemo.rlib" "output/libcobhandemo-${RLIB_SUFFIX}"
