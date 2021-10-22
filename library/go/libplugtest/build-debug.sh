#!/bin/sh

alias gccgo=gccgo-10

case $(uname -s) in
"Darwin")
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=c-shared -o output/libplugtest.dylib
    ;;

*)
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=c-shared -o output/libplugtest.so
    ;;
esac
