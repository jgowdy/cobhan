#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

#DOCKER=$(which podman 2>/dev/null || echo docker)
DOCKER=docker

$DOCKER build $DOCKER_BUILD_FLAGS -t libplugtest-linux - <Dockerfile.libplugtest-linux

MACHINE=$(uname -m)
rm libplugtest-linux-"$MACHINE".tar libplugtest.*

$DOCKER run --cidfile ./libplugtest-linux-cid libplugtest-linux

LIBPLUGTEST_CID=$(cat ./libplugtest-linux-cid)

$DOCKER export "$LIBPLUGTEST_CID" -o libplugtest-linux-"$MACHINE".tar

$DOCKER rm "$LIBPLUGTEST_CID"

rm ./libplugtest-linux-cid

tar -x --strip-components=1 -f libplugtest-linux-"$MACHINE".tar output/libplugtest.h output/libplugtest.so
