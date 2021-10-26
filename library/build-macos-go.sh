#!/bin/bash
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

pip3 install cffi

if [ "${IS_MACOS:-0}" -eq "1" ]; then

    rm -rf "${OUTPUT_BASE_DIR:-.}/go/macos"

    build "build.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/macos"

    build "build.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/macos"

fi
