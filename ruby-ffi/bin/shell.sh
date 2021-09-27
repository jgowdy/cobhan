#!/bin/sh

set -e

DOCKER_BUILD_FLAGS='--rm'

# Use --no-cache flag for docker to fetch latest libplugtest-binaries until it becomes versioned
# DOCKER_BUILD_FLAGS='--rm --no-cache'

DOCKER=$(which podman 2>/dev/null || echo docker)

distro=${1?"Usage: $0 distro"}

echo "=> Starting shell for $distro"
$DOCKER build . $DOCKER_BUILD_FLAGS -f docker/Dockerfile.ruby-"$distro"-demo -t ruby-"$distro"-demo:latest
$DOCKER run -it --rm ruby-"$distro"-demo sh
