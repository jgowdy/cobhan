#!/bin/sh
set -e
if [ -e ./.build/.build-shared.sh ]; then
    . ./.build/.build-shared.sh
else
    echo '.build/build-shared.sh is missing'
    exit 255
fi

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    echo "Compiling (Go) libcobhandemo-${DYN_SUFFIX} on macOS"
    CC=gcc CGO_ENABLED=1 go build -v -buildmode=c-shared \
        -o "target/libcobhandemo-${DYN_SUFFIX}" libcobhandemo.go
    ;;
"Linux")
    echo "Compiling (Go) libcobhandemo-${DYN_SUFFIX} on Linux"
    alias gccgo=gccgo-10
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -compiler=gccgo -buildmode=c-shared \
        -o "target/libcobhandemo-${DYN_SUFFIX}" libcobhandemo.go
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac

[ -e "target/libcobhandemo-${DYN_SUFFIX}" ] || (echo "target/libcobhandemo-${DYN_SUFFIX} does not exist" && exit 255)

# Test Go dynamic library file
python3 .test/test-libcobhandemo.py "target/libcobhandemo-${DYN_SUFFIX}"
if [ "$?" -eq "0" ]; then
    # Copy Go dynamic library file
    cp "target/libcobhandemo-${DYN_SUFFIX}" "output/libcobhandemo-${DYN_SUFFIX}"

    echo "Tests passed (Go): libcobhandemo-${DYN_SUFFIX}"
else
    echo "Tests failed (Go): libcobhandemo-${DYN_SUFFIX} Result: $?"
fi
