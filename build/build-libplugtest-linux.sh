#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t libplugtest-linux - <Dockerfile.libplugtest-linux

$DOCKER run --cidfile ./libplugtest-linux-cid libplugtest-linux

LIBPLUGTEST_CID=`cat ./libplugtest-linux-cid`
MACHINE=`uname -m`

$DOCKER export $LIBPLUGTEST_CID -o libplugtest-linux-$MACHINE.tar

$DOCKER rm $LIBPLUGTEST_CID

rm ./libplugtest-linux-cid

tar -x --strip-components=1 -f libplugtest-linux-musl-$MACHINE.tar output/libplugtest.*
