#!/bin/bash
ansible-playbook -vvv --vault-password-file=/project/.vaultpassword /project/playbook.yml -e env=$(echo "$DEPLOY_CONFIG" | sed 's/\.yml//g')
