#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`



$DOCKER build $DOCKER_BUILD_FLAGS -t libgo-linux-musl - <Dockerfile.libgo-linux-musl

$DOCKER run --cidfile ./libgo-linux-musl-cid libgo-linux-musl

LIBGO_CID=`cat ./libgo-linux-musl-cid`

$DOCKER export `cat ./libgo-linux-musl-cid` -o libgo-linux-musl-`uname -m`.tar

rm ./libgo-linux-musl-cid



