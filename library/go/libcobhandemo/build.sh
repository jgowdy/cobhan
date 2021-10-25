#!/bin/sh
set -e
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. ./.build-shared.sh

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=c-shared -o "output/libcobhandemo-${DYN_SUFFIX}"
    ;;
"Linux")
    alias gccgo=gccgo-10
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=c-shared -o "output/libcobhandemo-${DYN_SUFFIX}"
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac
