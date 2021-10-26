#!/bin/bash
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

rm -rf "${OUTPUT_BASE_DIR:-SAFE}/go/alpine" "${OUTPUT_BASE_DIR:-SAFE}rust/alpine"

build "build-alpine.sh" "rust/cobhan" "${OUTPUT_BASE_DIR}rust/alpine"

build "build-alpine.sh" "rust/libcobhandemo" "${OUTPUT_BASE_DIR}rust/alpine"

build "build-alpine.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/alpine"

build "build-alpine.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/alpine"
