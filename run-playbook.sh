#!/usr/bin/env bash
ansible-playbook -vv --vault-password-file=.vaultpassword $1 $2 $3
