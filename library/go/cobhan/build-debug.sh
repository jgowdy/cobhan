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

DEBUG="debug-"

case $(uname -s) in
"Darwin")
    EXT="-darwin.rlib"
    # gccgo does not support macOS
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=archive -o "output/libcobhan-${DEBUG}${SYS}${EXT}"
    ;;
"Linux")
    alias gccgo=gccgo-10
    EXT=".rlib"
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=archive -o "output/libcobhan-${DEBUG}${SYS}${EXT}"
    ;;
*)
    echo "Unknown system!"
    exit 255
    ;;
esac
