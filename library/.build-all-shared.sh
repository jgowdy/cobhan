#!/bin/sh

# OS Detection
case $(uname -s) in
"Darwin")
    IS_MACOS=1
    ;;
"Linux")
    IS_MACOS=0
    ;;
*)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac
export IS_MACOS

# Function to run build steps
# $1 name of script to run "build-buster.sh"
# $2 build directory
# $3 output directory "${OUTPUT_DIR}/rust/buster"
build() {
    SCRIPT_NAME="$1"
    BUILD_DIR="$2"
    OUTPUT_DIR="$3"
    SAVE_DIR=$(pwd)
    cd "${BUILD_DIR}"
    ./clean.sh
    "./${SCRIPT_NAME}"
    mkdir -p "${OUTPUT_DIR}"
    cp output/* "${OUTPUT_DIR}"
    cd "${SAVE_DIR}"
}
