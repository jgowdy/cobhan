#!/bin/sh
set -e
OUTPUT_DIR="$(pwd)/output"
rm -rf "${OUTPUT_DIR}"
. ./build-shared.sh

./build-macos.sh
./build-buster.sh
./build-bullseye.sh
./build-alpine.sh
