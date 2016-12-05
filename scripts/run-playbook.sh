#!/bin/bash
ansible-playbook -vvv --vault-password-file=/project/.vaultpassword /project/$DEPLOY_CONFIG