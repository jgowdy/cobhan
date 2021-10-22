#!/bin/sh

case $(uname -s) in
"Darwin")
    ;;
*)
    docker build -f Dockerfile.alpine -t cobhan-go-alpine . && CID=$(docker create cobhan-go-alpine) && docker cp ${CID}:/output . && docker rm ${CID}
    ;;
esac

