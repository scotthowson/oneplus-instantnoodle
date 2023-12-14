#!/bin/bash
set -xe

[ -d build ] || git clone https://gitlab.com/ubports/community-ports/halium-generic-adaptation-build-tools -b halium-12 build
./build/build.sh "$@"
