#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t libplugtest-linux-musl - <Dockerfile.libplugtest-linux-musl

rm libplugtest-linux-musl.tar libgo.so.16.0.0

$DOCKER run --cidfile ./libplugtest-linux-musl-cid libplugtest-linux-musl

LIBPLUGTEST_CID=`cat ./libplugtest-linux-musl-cid`
MACHINE=`uname -m`

$DOCKER export $LIBPLUGTEST_CID -o libplugtest-linux-musl-$MACHINE.tar

$DOCKER rm $LIBPLUGTEST_CID

rm ./libplugtest-linux-musl-cid

tar -x --strip-components=1 -f libplugtest-linux-musl-$MACHINE.tar output/libplugtest.*
