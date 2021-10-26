#!/bin/sh
set -e

echo "Preparing build directory $(pwd)"

# Make the build directory
mkdir -p .build/

# Copy the build shared shell script into the build directory
cp ../../.build-shared.sh .build/.build-shared.sh

# Make the test directory
mkdir -p ./.test/

# Copy the test Python scripts into the test directory
cp ../../../ffi/python3/*.py ./.test/

# Create the output directory
mkdir -p ./output
