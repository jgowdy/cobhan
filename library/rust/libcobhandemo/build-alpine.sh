#!/bin/sh

mkdir -p output

case $(uname -s) in
"Darwin")
    echo "Skipping build-alpine.sh due to Darwin/macOS"
    ;;
"Linux")
    docker build -f Dockerfile.alpine -t libcobhandemo-go-alpine .. && CID=$(docker create libcobhandemo-go-alpine) && docker cp "${CID}":/output ./output/ && docker rm "${CID}"
    ;;
*)
    echo "Unknown system!"
    exit 255
    ;;
esac
