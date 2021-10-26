#!/bin/bash

# Create output directory
mkdir -p ./output/

# Allow the docker binary name to be overriden with DOCKER_BIN
DOCKER_BIN="${DOCKER_BIN:-docker}"

# If DEBUG is set, add debug- to the file names
if [ "${DEBUG:-0}" -eq "1" ]; then
    DEBUG_FN_PART="debug-"
else
    DEBUG_FN_PART=""
fi

# Normalize machine architecture for file names
case $(uname -m) in
"x86_64")
    SYS_FN_PART="x64"
    ;;
"aarch64")
    SYS_FN_PART="arm64"
    ;;
"arm64")
    SYS_FN_PART="arm64"
    ;;
*)
    echo "Unknown machine $(uname -m)!"
    exit 255
    ;;
esac

# If ALPINE is set, include musl in the file name
if [ "${ALPINE:-0}" -eq "1" ]; then
    SYS_FN_PART="musl-${SYS_FN_PART}"
fi

# OS Detection
case $(uname -s) in
"Darwin")
    IS_MACOS=1
    DYN_EXT=".dylib"
    RUST_EXT="-darwin.rlib"
    A_EXT="-darwin.a"
    ;;
"Linux")
    IS_MACOS=0
    DYN_EXT=".so"
    RUST_EXT=".rlib"
    A_EXT=".a"
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac
export IS_MACOS
export DYN_EXT
export RUST_EXT
export A_EXT

# Create dynamic library file name suffix
DYN_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${DYN_EXT}"
export DYN_SUFFIX

# Create Rust static library file name suffix
RLIB_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${RUST_EXT}"
export RLIB_SUFFIX

# Create C archive (static library) file name suffix
ALIB_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${A_EXT}"
export ALIB_SUFFIX

