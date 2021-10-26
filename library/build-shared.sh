#!/bin/bash
mkdir -p ./test/
[ -e ../../../ffi/python3/cobhan.py ] && cp ../../../ffi/python3/*.py ./test/

DOCKER_BIN="${DOCKER_BIN:-docker}"

if [ "${DEBUG:-0}" -eq "1" ]; then
    DEBUG_FN_PART="debug-"
else
    DEBUG_FN_PART=""
fi

# Normalize machine architecture

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

if [ "${ALPINE:-0}" -eq "1" ]; then
    SYS_FN_PART="musl-${SYS_FN_PART}"
fi

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

export DYN_EXT
export RUST_EXT

DYN_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${DYN_EXT}"
export DYN_SUFFIX

RLIB_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${RUST_EXT}"
export RLIB_SUFFIX

ALIB_SUFFIX="${DEBUG_FN_PART}${SYS_FN_PART}${A_EXT}"
export ALIB_SUFFIX

mkdir -p output
