#!/bin/sh
set -e
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. ./.build-shared.sh

TAG="libcobhandemo-go-buster"
CONTEXT_DIR=".."

case $(uname -s) in
"Darwin")
    if [ "${SKIP_MAC:-0}" -ne "0" ]; then
        echo "Skipping build-buster.sh due to SKIP_MAC=1 on Darwin/macOS"
        exit 255
    fi
    ;;
"Linux")
    true
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac

"${DOCKER_BIN}" build -f Dockerfile.buster -t ${TAG} ${CONTEXT_DIR}
CID="$( ${DOCKER_BIN} create ${TAG} )"
docker cp ${CID}:/libcobhandemo/output .
docker rm ${CID}
