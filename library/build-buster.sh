#!/bin/sh
set -e
OUTPUT_DIR="$(pwd)/output"
. ./build-shared.sh

pushd go/cobhan
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/go/buster/" && cp output/* "${OUTPUT_DIR}/go/buster"
popd

pushd go/libcobhandemo
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/go/buster/" && cp output/* "${OUTPUT_DIR}/go/buster"
popd

pushd rust/cobhan
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/rust/buster/" && cp output/* "${OUTPUT_DIR}/rust/buster"
popd

pushd rust/libcobhandemo
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/rust/buster/" && cp output/* "${OUTPUT_DIR}/rust/buster"
popd
