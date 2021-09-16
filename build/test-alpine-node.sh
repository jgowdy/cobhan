#!/bin/bash

DOCKER_BUILD_FLAGS='--rm'

DOCKER=`which podman 2>/dev/null || echo docker`


$DOCKER build $DOCKER_BUILD_FLAGS -t node-alpine-demo - <Dockerfile.node-alpine-demo


