#!/bin/bash
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

rm -rf "${OUTPUT_DIR:-.}/go/buster"

build "build-buster.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/buster"

build "build-buster.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/buster"
