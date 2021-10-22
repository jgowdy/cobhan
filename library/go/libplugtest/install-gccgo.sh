#!/bin/sh

case $(uname -s) in
"Darwin")
*)
    sudo apt install -y gccgo
    ;;
esac


