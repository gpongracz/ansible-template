#!/bin/bash

# You shouldn't have to run this file
# This describes how Docker Hub will build the images based on tags

ANSIBLE_BRANCH=devel
ANSIBLE_VERSION=2.3.0
ANSIBLE_COMMIT_HASH=f28b5a0ed86d9b007744b7815cb2ca4a283275f4
DOCKER_TAG=$ANSIBLE_BRANCH-$ANSIBLE_VERSION-$ANSIBLE_COMMIT_HASH

docker build . -t simplemachines/ansible-template:$DOCKER_TAG
