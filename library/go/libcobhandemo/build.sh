#!/bin/sh
set -e
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. ./.build-shared.sh

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=c-shared \
        -o "target/libcobhandemo-${DYN_SUFFIX}" libcobhandemo.go
    ;;
"Linux")
    alias gccgo=gccgo-10
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=c-shared \
        -o "target/libcobhandemo-${DYN_SUFFIX}" libcobhandemo.go
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac

# Test Go dynamic library file
python3 test/test.py "target/libcobhandemo-${DYN_SUFFIX}"
if [ "$?" -eq "0" ]; then
    echo "Tests passed"
    # Copy Go dynamic library file
    cp "target/libcobhandemo-${DYN_SUFFIX}" "output/libcobhandemo-${DYN_SUFFIX}"
else
    echo "Tests failed"
fi
