#!/usr/bin/env bash
set -e
curl -L -o /tmp/ansible-template-latest.zip https://github.com/simple-machines/ansible-template/archive/master.zip
unzip /tmp/ansible-template-latest.zip
rm ansible-template-latest/dev/vars/*
rm ansible-template-latest/prod/vars/*
mv ansible-template-latest/* .
