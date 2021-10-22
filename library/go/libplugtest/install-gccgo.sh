#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping gccgo install due to Darwin/macOS"
    ;;
*)
    sudo apt install -y gccgo
    ;;
esac


