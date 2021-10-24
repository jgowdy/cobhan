#!/bin/sh

mkdir -p output

case $(uname -m) in
"x86_64")
    SYS="x64"
    ;;
"arm64")
    SYS="arm64"
    ;;
*)
    echo "Unknown machine!"
    exit 255
    ;;
esac

case $(uname -s) in
"Darwin")
    EXT="-darwin.rlib"
    ;;
"Linux")
    EXT=".rlib"
    ;;
*)
    echo "Unknown system!"
    exit 255
    ;;
esac

DEBUG="debug-"
cargo build --features cobhan_debug --verbose
cp "target/debug/libcobhan${EXT}" "output/libcobhan-${DEBUG}${SYS}${EXT}"
