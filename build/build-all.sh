#!/bin/sh

./build-clone.sh

./build-libgo-linux-musl.sh

./build-libplugtest-linux-musl.sh

./test-alpine-node.sh
