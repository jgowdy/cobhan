#!/bin/sh
set -e

OUTPUT_DIR="$(pwd)/output"
rm -rf "${OUTPUT_DIR:-SAFE}"

./build-macos-go.sh
./build-macos-rust.sh
./build-bullseye-go.sh
./build-bullseye-rust.sh
