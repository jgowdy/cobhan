#!/bin/sh
set -e

OUTPUT_DIR="$(pwd)/output"
rm -rf "${OUTPUT_DIR:-SAFE}"


./build-macos.sh
./build-buster.sh
./build-bullseye.sh
./build-alpine.sh
