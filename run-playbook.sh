#!/usr/bin/env bash
ansible-playbook -vvv --vault-password-file=.vaultpassword $1 $2 $3
