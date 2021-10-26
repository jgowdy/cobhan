#!/bin/sh
set -e
OUTPUT_DIR="$(pwd)/output"
. build-shared.sh

rm -rf "${OUTPUT_DIR:-.}/go/bullseye" "${OUTPUT_DIR:-.}/rust/bullseye"

pushd go/cobhan
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/go/bullseye/" && cp -f output/* "${OUTPUT_DIR}/go/bullseye"
popd

pushd go/libcobhandemo
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/go/bullseye/" && cp -f output/* "${OUTPUT_DIR}/go/bullseye"
popd

pushd rust/cobhan
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/rust/bullseye/" && cp -f output/* "${OUTPUT_DIR}/rust/bullseye"
popd

pushd rust/libcobhandemo
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/rust/bullseye/" && cp -f output/* "${OUTPUT_DIR}/rust/bullseye"
popd
