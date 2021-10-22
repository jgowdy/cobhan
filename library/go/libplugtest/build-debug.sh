#!/bin/sh


case $(uname -s) in
"Darwin")
    CC=gcc CGO_ENABLED=1 go build -buildmode=c-shared -o output/libplugtest.dylib
    ;;

*)
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -compiler=gccgo-10 -buildmode=c-shared -o /output/libplugtest.so
    ;;
esac
