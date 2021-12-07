#!/bin/sh
set -e
if [ -e ./.build/.build-shared.sh ]; then
    . ./.build/.build-shared.sh
else
    echo '.build/build-shared.sh is missing'
    exit 255
fi

if [ "${DEBUG:-0}" -eq "1" ]; then
    GO_BUILD_ARGS="-tags=debugoutput"
else
    GO_BUILD_ARGS=""
fi

if [ "${ALPINE:-0}" -eq "1" ]; then
    GO_BUILD_ARGS=" ${GO_BUILD_ARGS} -compiler=gccgo "
fi

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=archive \
        ${GO_BUILD_ARGS} -o "output/libcobhan-${ALIB_SUFFIX}"
    ;;
"Linux")
    alias gccgo=gccgo-10
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -buildmode=archive \
        ${GO_BUILD_ARGS} -o "output/libcobhan-${ALIB_SUFFIX}"
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac
