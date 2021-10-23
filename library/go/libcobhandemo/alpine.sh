#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping alpine.sh due to Darwin/macOS"
    ;;
*)
    docker build -f libcobhandemo/Dockerfile.alpine -t libcobhandemo-go-alpine . && CID=$(docker create libcobhandemo-go-alpine) && docker cp ${CID}:/output ./libcobhandemo && docker rm ${CID}
    ;;
esac
