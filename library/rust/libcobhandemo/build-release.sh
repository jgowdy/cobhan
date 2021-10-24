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
    EXT=".dylib"
    ;;
"Linux")
    EXT=".so"
    ;;
*)
    echo "Unknown system!"
    exit 255
    ;;
esac

DEBUG=""
cargo build --verbose --release
cp "target/release/libcobhandemo${EXT}" "output/libcobhandemo-${DEBUG}${SYS}${EXT}"
cp "target/debug/libcobhandemo.rlib" "output/libcobhandemo-${DEBUG}${SYS}.rlib"
