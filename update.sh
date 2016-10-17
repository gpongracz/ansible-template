#!/usr/bin/env bash
set -e
VERSION=master
rm -Rf ansible-template-$VERSION
curl -L https://github.com/simple-machines/ansible-template/archive/$VERSION.tar.gz | tar xz
rm ansible-template-$VERSION/roles/dev/vars/*
rm ansible-template-$VERSION/roles/prod/vars/*
rsync -ra ansible-template-$VERSION/* .
rm -Rf ansible-template-$VERSION
