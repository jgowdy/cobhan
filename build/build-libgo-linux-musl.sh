#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=$(which podman 2>/dev/null || echo docker)

$DOCKER build $DOCKER_BUILD_FLAGS -t libgo-linux-musl - <Dockerfile.libgo-linux-musl

MACHINE=$(uname -m)
rm libgo-linux-musl-$MACHINE.tar libgo.so.16.0.0
rm -rf aarch64

$DOCKER run --cidfile ./libgo-linux-musl-cid libgo-linux-musl

LIBGO_CID=$(cat ./libgo-linux-musl-cid)

$DOCKER export $LIBGO_CID -o libgo-linux-musl-$MACHINE.tar

$DOCKER rm -f $LIBGO_CID

rm ./libgo-linux-musl-cid

tar -x --strip-components=9 -f libgo-linux-musl-$MACHINE.tar home/build/aports/main/gcc/pkg/libgo/usr/lib/libgo.so.16.0.0
tar -x --strip-components=4 -f libgo-linux-musl-$MACHINE.tar home/build/packages
