#!/bin/sh
docker build -f Dockerfile.alpine -t cobhan-go-alpine . && CID=$(docker create cobhan-go-alpine) && docker cp ${CID}:/output . && docker rm ${CID}
