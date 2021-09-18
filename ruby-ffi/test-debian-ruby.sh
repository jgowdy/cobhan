#!/bin/bash

set -e

DOCKER_BUILD_FLAGS='--rm'

# Use --no-cache flag for docker to fetch latest libplugtest-binaries until it becomes versioned
# DOCKER_BUILD_FLAGS='--rm --no-cache'

DOCKER=`which podman 2>/dev/null || echo docker`

$DOCKER build . $DOCKER_BUILD_FLAGS -f Dockerfile.ruby-debian-demo -t ruby-debian-demo:latest

$DOCKER run ruby-debian-demo
