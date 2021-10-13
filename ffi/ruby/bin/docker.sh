#!/bin/bash

set -e

DOCKER_BUILD_FLAGS='--rm'

# Use --no-cache flag for docker to fetch latest libplugtest-binaries until it becomes versioned
# DOCKER_BUILD_FLAGS='--rm --no-cache'

DOCKER=`which podman 2>/dev/null || echo docker`

DISTRO="${DISTRO:-alpine}"
cmd=${@:-"sh"}

echo "=> Building $DISTRO docker"
$DOCKER build . $DOCKER_BUILD_FLAGS -f docker/Dockerfile.ruby-$DISTRO -t ruby-cobhan-$DISTRO:latest

if [[ $cmd == "sh" && ! $DOCKER_BUILD_FLAGS =~ "-it" ]]; then
  DOCKER_BUILD_FLAGS="$DOCKER_BUILD_FLAGS -it"
fi

$DOCKER run $DOCKER_BUILD_FLAGS --ulimit memlock=-1:-1 ruby-cobhan-$DISTRO:latest $cmd
