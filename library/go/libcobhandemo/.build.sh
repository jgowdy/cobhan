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

if [ "${ALPINE}" -eq "1" ]; then
    GO_BUILD_ARGS=" ${GO_BUILD_ARGS} -compiler=gccgo "
fi

case $(uname -s) in
"Darwin")
    # gccgo does not support macOS
    echo "Compiling (Go) libcobhandemo-${DYN_SUFFIX} on macOS"
    LD_RUN_PATH=\$ORIGIN CC=gcc CGO_ENABLED=1 go build -v -buildmode=c-shared \
        ${GO_BUILD_ARGS} -o "target/libcobhandemo-${DYN_SUFFIX}"
    ;;
"Linux")
    echo "Compiling (Go) libcobhandemo-${DYN_SUFFIX} on Linux"
    LD_RUN_PATH=\$ORIGIN CGO_ENABLED=1 go build -v -buildmode=c-shared \
        ${GO_BUILD_ARGS} -o "target/libcobhandemo-${DYN_SUFFIX}"
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac

[ -e "target/libcobhandemo-${DYN_SUFFIX}" ] || (echo "target/libcobhandemo-${DYN_SUFFIX} does not exist" && exit 255)

# Test Go dynamic library file
count=0
while [ $count -lt 20 ]
do
    echo "Test iteration ${count}"
    python3 .test/test-libcobhandemo.py "target/libcobhandemo-${DYN_SUFFIX}"
    if [ "$?" -eq "0" ]; then
        echo "Passed"
    else
        echo "Tests failed (Go): libcobhandemo-${DYN_SUFFIX} Result: $?"
        exit 255
    fi
    count=`expr ${count} + 1`
done

# Copy Go dynamic library file
echo "Tests passed (Go): libcobhandemo-${DYN_SUFFIX}"
cp "target/libcobhandemo-${DYN_SUFFIX}" "output/libcobhandemo-${DYN_SUFFIX}"
