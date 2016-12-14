#!/usr/bin/env bash
ANSIBLE_BRANCH=devel
ANSIBLE_VERSION=2.3.0
ANSIBLE_COMMIT_HASH=f28b5a0ed86d9b007744b7815cb2ca4a283275f4
DOCKER_TAG=$ANSIBLE_BRANCH-$ANSIBLE_VERSION-$ANSIBLE_COMMIT_HASH

docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws -e TARGET_ENV=$1 simplemachines/ansible-template:$DOCKER_TAG scripts/editvault.sh
