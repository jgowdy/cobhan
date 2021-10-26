#!/bin/sh
set -e
OUTPUT_DIR="$(pwd)/output"
rm -rf "${OUTPUT_DIR}"
. build-shared.sh

pushd go/cobhan
if [ "${IS_MACOS:-0}" -eq "1" ]; then
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/go/macos/" && cp output/* "${OUTPUT_DIR}/go/macos/"
fi
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/go/bullseye/" && cp output/* "${OUTPUT_DIR}/go/bullseye"
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/go/buster/" && cp output/* "${OUTPUT_DIR}/go/buster"
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/go/alpine/" && cp output/* "${OUTPUT_DIR}/go/alpine"
popd


pushd go/libcobhandemo
if [ "${IS_MACOS:-0}" -eq "1" ]; then
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/go/macos/" && cp output/* "${OUTPUT_DIR}/go/macos/"
fi
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/go/bullseye/" && cp output/* "${OUTPUT_DIR}/go/bullseye"
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/go/buster/" && cp output/* "${OUTPUT_DIR}/go/buster"
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/go/alpine/" && cp output/* "${OUTPUT_DIR}/go/alpine"
popd

pushd rust/cobhan
if [ "${IS_MACOS:-0}" -eq "1" ]; then
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/rust/macos/" && cp output/* "${OUTPUT_DIR}/rust/macos/"
fi
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/rust/bullseye/" && cp output/* "${OUTPUT_DIR}/rust/bullseye"
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/rust/buster/" && cp output/* "${OUTPUT_DIR}/rust/buster"
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/rust/alpine/" && cp output/* "${OUTPUT_DIR}/rust/alpine"
popd

pushd rust/libcobhandemo
if [ "${IS_MACOS:-0}" -eq "1" ]; then
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/rust/macos/" && cp output/* "${OUTPUT_DIR}/rust/macos/"
fi
./clean.sh && ./build-bullseye.sh && mkdir -p "${OUTPUT_DIR}/rust/bullseye/" && cp output/* "${OUTPUT_DIR}/rust/bullseye"
./clean.sh && ./build-buster.sh && mkdir -p "${OUTPUT_DIR}/rust/buster/" && cp output/* "${OUTPUT_DIR}/rust/buster"
./clean.sh && ./build-alpine.sh && mkdir -p "${OUTPUT_DIR}/rust/alpine/" && cp output/* "${OUTPUT_DIR}/rust/alpine"
popd
