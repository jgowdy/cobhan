#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping alpine.sh due to Darwin/macOS"
    ;;
*)
    docker build -f Dockerfile.alpine -t cobhan-go-alpine . && CID=$(docker create cobhan-go-alpine) && docker cp ${CID}:/output . && docker rm ${CID}
    ;;
esac

