#!/usr/bin/env bash
docker run -it -v $(pwd):/project -v ~/.aws:/root/.aws -e TARGET_ENV=$1 simplemachines/ansible-template scripts/editvault.sh