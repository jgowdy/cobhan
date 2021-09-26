#!/bin/bash

./build-clone.sh

DOCKER_BUILD_FLAGS='--rm'

DOCKER=$(which podman 2>/dev/null || echo docker)

$DOCKER build $DOCKER_BUILD_FLAGS -t ruby-debian-demo - <Dockerfile.ruby-debian-demo

$DOCKER run ruby-debian-demo
