#!/usr/bin/env bash
source ANSIBLE_DOCKER_ENV

docker run -it -v "$(pwd):/project" -v ~/.aws:/root/.aws -e DEPLOY_CONFIG=$1 simplemachines/ansible-template:$DOCKER_TAG scripts/run-playbook.sh
