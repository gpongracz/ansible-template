#!/usr/bin/env bash
docker run -it -v $(pwd):/project -v ~/.aws:/root/.aws -e DEPLOY_CONFIG=$1 simplemachines/ansible-template scripts/run-playbook.sh