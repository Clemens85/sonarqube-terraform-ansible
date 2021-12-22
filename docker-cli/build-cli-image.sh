#! /bin/bash

CUR_DIR=$(pwd)
cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

docker build -t "$DOCKER_IMAGE" .

cd "$CUR_DIR" || exit 1