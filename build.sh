#!/bin/bash
set -xe

ADAPTATION_TOOLS_BRANCH=main

if [ ! -d build ]; then
  git clone -b $ADAPTATION_TOOLS_BRANCH https://gitlab.com/ubports/community-ports/halium-generic-adaptation-build-tools build
fi

./build/build.sh "$@"