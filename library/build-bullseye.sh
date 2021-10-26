#!/bin/sh
set -e
OUTPUT_BASE_DIR="$(pwd)/output/"
. ./.build-all-shared.sh

rm -rf "${OUTPUT_BASE_DIR:-.}/go/bullseye" "${OUTPUT_BASE_DIR:-.}rust/bullseye"

build "build-bullseye.sh" "rust/cobhan" "${OUTPUT_BASE_DIR}rust/bullseye"

build "build-bullseye.sh" "rust/libcobhandemo" "${OUTPUT_BASE_DIR}rust/bullseye"

build "build-bullseye.sh" "go/cobhan" "${OUTPUT_BASE_DIR}go/bullseye"

build "build-bullseye.sh" "go/libcobhandemo" "${OUTPUT_BASE_DIR}go/bullseye"

