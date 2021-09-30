#!/bin/sh

case $(uname -s) in
"Darwin") ;;

*)
    echo 'Requires macOS'
    exit 255
    ;;
esac

# Build MacOS for arm64
echo "Build MacOS for arm64"
CC=gcc CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -buildmode=c-shared -o output/macos/arm64/libplugtest.dylib main.go
echo ""

# Build MacOS for amd64
echo "Build MacOS for amd64"
CC=gcc CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -buildmode=c-shared -o output/macos/amd64/libplugtest.dylib main.go
echo ""
