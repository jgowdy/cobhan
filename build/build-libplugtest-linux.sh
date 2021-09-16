#!/bin/sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t libplugtest-linux - <Dockerfile.libplugtest-linux

$DOCKER run --cidfile ./libplugtest-linux-cid libplugtest-linux

LIBPLUGTEST_CID=`cat ./libplugtest-linux-cid`

$DOCKER export $LIBPLUGTEST_CID -o libplugtest-linux-`uname -m`.tar

$DOCKER rm $LIBPLUGTEST_CID

rm ./libplugtest-linux-cid





