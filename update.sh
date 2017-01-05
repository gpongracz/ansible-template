#!/usr/bin/env bash
set -e
if [ ! -z "$1" ]
  then
    echo "Updating from $1"
    UPDATE_FROM=$1
  else
    echo "Updating from github"
    VERSION=master
    rm -Rf ansible-template-$VERSION
    curl -L https://github.com/simple-machines/ansible-template/archive/$VERSION.tar.gz | tar xz
    UPDATE_FROM="ansible-template-$VERSION"
fi

# This leaves in place all local vars but does override template-owned default vars
rsync --exclude 'roles/dev/vars' --exclude 'roles/prod/vars' \
      --exclude 'roles/infra/vars' --exclude 'roles/'-rav $UPDATE_FROM/* .

rsync --include='roles/default' --include 'roles/infra/' include='template/' --exclude='*/' …
