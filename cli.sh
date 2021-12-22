#! /bin/bash

CUR_DIR=$(pwd)
cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source config/config.sh

REPO_DIR=$(pwd)

docker run --tty -it \
            -v "${REPO_DIR}":/workspace \
            -v "${HOME}"/.ssh:/home/provisioning/.ssh-host:ro \
            -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
            -w /workspace \
            "${DOCKER_IMAGE}" 

cd "$CUR_DIR" || exit 1
