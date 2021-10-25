#!/bin/sh

mkdir -p output/go
mkdir -p output/rust

pushd go/cobhan
./clean.sh
./build.sh
./build-alpine.sh
./build-bullseye.sh
./build-buster.sh
popd

cp go/cobhan/output/* output/go/

pushd go/libcobhandemo
./clean.sh
./build.sh
./build-alpine.sh
./build-bullseye.sh
./build-buster.sh
popd

cp go/libcobhandemo/output/* output/go/

pushd rust/libcobhan
./clean.sh
./build.sh
./build-alpine.sh
./build-bullseye.sh
./build-buster.sh
popd

cp rust/libcobhan/output/* output/rust/

pushd rust/libcobhandemo
./clean.sh
./build.sh
./build-alpine.sh
./build-bullseye.sh
./build-buster.sh
popd

cp rust/libcobhandemo/output/* output/rust/
