#!/usr/bin/env bash
set -e
VERSION=master
rm -Rf ansible-template-$VERSION
curl -L https://github.com/simple-machines/ansible-template/archive/$VERSION.tar.gz | tar xvf
rm ansible-template-$VERSION/dev/vars/*
rm ansible-template-$VERSION/prod/vars/*
mv ansible-template-$VERSION/* .
rmdir ansible-template-$VERSION
