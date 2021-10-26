#!/bin/sh
set -e

# Prepare the build directory
. ../../.build-prepare.sh

DOCKER_BIN="${DOCKER_BIN:-docker}"
TAG="cobhan-rust-bullseye"
CONTEXT_DIR="."

if [ "${DEBUG:-0}" -eq "1" ]; then
    export DOCKER_BUILDKIT=0
fi

"${DOCKER_BIN}" build -f Dockerfile.bullseye -t ${TAG} ${CONTEXT_DIR}
CID="$( ${DOCKER_BIN} create ${TAG} )"
docker cp ${CID}:/cobhan/output .
docker rm ${CID}
