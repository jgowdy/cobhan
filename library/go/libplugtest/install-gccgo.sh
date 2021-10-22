#!/bin/sh

case $(uname -s) in
"Darwin")
    echo "Skipping gccgo install due to Darwin/macOS"
    ;;
*)
    sudo apt-get install -y gccgo-10
    ;;
esac


