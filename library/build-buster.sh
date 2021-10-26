#!/bin/bash
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

rm -rf "${OUTPUT_DIR:-.}/go/buster" "${OUTPUT_DIR:-.}rust/buster"

build "build-buster.sh" "rust/cobhan" "${OUTPUT_BASE_DIR}rust/buster"

build "build-buster.sh" "rust/libcobhandemo" "${OUTPUT_BASE_DIR}rust/buster"

build "build-buster.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/buster"

build "build-buster.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/buster"




