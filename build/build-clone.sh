#!/bin/sh

DOCKER_CLONE_FLAGS='--no-cache'

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`

$DOCKER build $DOCKER_CLONE_FLAGS $DOCKER_BUILD_FLAGS -t cobhan-clone - <Dockerfile.cobhan-clone

$DOCKER build $DOCKER_CLONE_FLAGS $DOCKER_BUILD_FLAGS -t libplugtest-binaries-clone - <Dockerfile.libplugtest-binaries-clone


