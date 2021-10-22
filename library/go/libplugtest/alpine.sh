#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping alpine.sh due to Darwin/macOS"
    ;;
*)
    docker build -f libplugtest/Dockerfile.alpine -t libplugtest-go-alpine . && CID=$(docker create libplugtest-go-alpine) && docker cp ${CID}:/output ./libplugtest && docker rm ${CID}
    ;;
esac

