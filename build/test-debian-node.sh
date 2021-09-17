#!/bin/bash

./build-clone.sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t node-debian-demo - <Dockerfile.node-debian-demo

$DOCKER run node-debian-demo

