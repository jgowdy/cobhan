#!/bin/bash

if [[ "$OSTYPE" != "darwin"* ]]; then
	echo 'Requires macOS'
	exit -1
fi

# Build MacOS for arm64
echo "Build MacOS for arm64"
CC=gcc CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -buildmode=c-shared -o output/macos/arm64/libplugtest.dylib main.go
echo ""

# Build MacOS for amd64
echo "Build MacOS for amd64"
CC=gcc CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -buildmode=c-shared -o output/macos/amd64/libplugtest.dylib main.go
echo ""

