#!/bin/sh
set -e
[ -e ../../build-shared.sh ] && cp ../../build-shared.sh .build-shared.sh
. .build-shared.sh

TAG="libcobhandemo-go-alpine"

case $(uname -s) in
"Darwin")
    if [ "${SKIP_MAC:-0}" -ne "0" ]; then
        echo "Skipping build-alpine.sh due to SKIP_MAC=1 on Darwin/macOS"
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

"${DOCKER_BIN}" build -f Dockerfile.alpine -t ${TAG} .
CID="$( ${DOCKER_BIN} create ${TAG} )"
docker cp ${CID}:/cobhan/output .
docker rm ${CID}
