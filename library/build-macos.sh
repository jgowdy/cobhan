#!/bin/bash
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

if [ "${IS_MACOS:-0}" -eq "1" ]; then

    rm -rf "${OUTPUT_BASE_DIR:-.}/go/macos" "${OUTPUT_BASE_DIR:-.}rust/macos"

    build "build.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/macos"

    build "build.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/macos"

    build "build.sh" "rust/cobhan" "${OUTPUT_BASE_DIR}rust/macos"

    build "build.sh" "rust/libcobhandemo" "${OUTPUT_BASE_DIR}rust/macos"

fi
