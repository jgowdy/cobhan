#!/bin/bash
set -e
OUTPUT_DIR="$(pwd)/output"
. ./build-shared.sh

rm -rf "${OUTPUT_DIR:-.}/go/alpine" "${OUTPUT_DIR:-.}/rust/alpine"

pushd go/cobhan
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/go/alpine/" && cp -f output/* "${OUTPUT_DIR}/go/alpine"
popd

pushd go/libcobhandemo
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/go/alpine/" && cp -f output/* "${OUTPUT_DIR}/go/alpine"
popd

pushd rust/cobhan
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/rust/alpine/" && cp -f output/* "${OUTPUT_DIR}/rust/alpine"
popd

pushd rust/libcobhandemo
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/rust/alpine/" && cp -f output/* "${OUTPUT_DIR}/rust/alpine"
popd
