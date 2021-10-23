#!/bin/sh

alias gccgo=gccgo-10

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=archive -o output/cobhan.a
    ;;
*)
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=archive -o output/cobhan.a
    ;;
esac
