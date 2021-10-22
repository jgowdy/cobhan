#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping alpine.sh due to Darwin/macOS"
    ;;
*)
    docker build -f cobhan-demo-lib/Dockerfile.alpine -t cobhan-demo-lib-go-alpine . && CID=$(docker create cobhan-demo-lib-go-alpine) && docker cp ${CID}:/output ./cobhan-demo-lib && docker rm ${CID}
    ;;
esac

