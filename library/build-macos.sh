#!/bin/bash
set -e
OUTPUT_DIR="$(pwd)/output"
. ./build-shared.sh

if [ "${IS_MACOS:-0}" -eq "1" ]; then
    pushd go/cobhan
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/go/macos/" && cp output/* "${OUTPUT_DIR}/go/macos/"
    popd

    pushd go/libcobhandemo
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/go/macos/" && cp output/* "${OUTPUT_DIR}/go/macos/"
    popd

    pushd rust/cobhan
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/rust/macos/" && cp output/* "${OUTPUT_DIR}/rust/macos/"
    popd

    pushd rust/libcobhandemo
    ./clean.sh && ./build.sh && mkdir -p "${OUTPUT_DIR}/rust/macos/" && cp output/* "${OUTPUT_DIR}/rust/macos/"
    popd
fi
