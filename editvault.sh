#!/usr/bin/env bash
source ANSIBLE_DOCKER_ENV

docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws -e TARGET_ENV=$1 simplemachines/ansible-template:$DOCKER_TAG scripts/editvault.sh
