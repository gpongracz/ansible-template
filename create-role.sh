#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied"; exit 1
fi

# this script is used to create a role
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR=$DIR/roles/$1
TEMPLATE_DIR=$DIR/roles/template
if [ ! -d "$TARGET_DIR" ]; then
  # Control will enter here if $DIRECTORY exists.
  cp -R $TEMPLATE_DIR $TARGET_DIR/
else
  echo "$TARGET_DIR already exists"
fi
