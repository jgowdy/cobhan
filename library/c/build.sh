#!/bin/sh

[ "${CONSOLE:-0}" -eq "1" ] && COMPILE_FLAGS="-o libplugtest libplugtest-tests.c" || COMPILE_FLAGS="-shared -init _init -o libplugtest.so"
cc -I/usr/local/include -I/usr/local/opt/apr/include/apr-1 -I/usr/local/opt/apr-util/libexec/include/apr-1 -l apr-1 -l aprutil-1 -l unistring ${COMPILE_FLAGS} libplugtest.c cJSON.c
