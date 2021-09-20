#!/bin/bash

set -e

DOCKER_BUILD_FLAGS='--rm'

# Use --no-cache flag for docker to fetch latest libplugtest-binaries until it becomes versioned
# DOCKER_BUILD_FLAGS='--rm --no-cache'

DOCKER=`which podman 2>/dev/null || echo docker`

distros=${1:-"alpine debian"}
for distro in $distros
do
  echo "=> Building gem and running smoke tests for $distro"
  $DOCKER build . $DOCKER_BUILD_FLAGS -f docker/Dockerfile.ruby-$distro-demo -t ruby-$distro-demo:latest
  $DOCKER run ruby-$distro-demo sh -c "ruby spec/build_smoke_test.rb"
done
