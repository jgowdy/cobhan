#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t libplugtest-linux-musl - <Dockerfile.libplugtest-linux-musl

$DOCKER run --cidfile ./libplugtest-linux-musl-cid libplugtest-linux-musl

LIBPLUGTEST_CID=`cat ./libplugtest-linux-musl-cid`

$DOCKER export $LIBPLUGTEST_CID -o libplugtest-linux-musl-`uname -m`.tar

$DOCKER rm $LIBPLUGTEST_CID

rm ./libplugtest-linux-musl-cid





