#!/usr/bin/env bash
set -e
if ! [ -a .vaultpassword ]
then
    echo "Vault password file '.vaultpassword' not found."
    exit 1
fi
command -v ansible-vault >/dev/null 2>&1 || { echo "Please install ansible-vault before running this script." >&2; exit 1; }
ansible-vault --vault-password-file=.vaultpassword edit roles/$1/vars/secret.yml
