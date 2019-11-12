#!/bin/bash

# start-docker.sh

set -e

IMAGE_NAME="mod-nightly-custom-op-ubuntu16"

# create named container if arg given (--rm default)
if [ -z $1 ]; then
    CNAME="--rm"
else
    CNAME="--name $1"
    # if container already exists, confirm removal
    if [ $(docker ps -aq -f name=$1) ]; then
       read -p "Container already exists, overwrite? (y/n) " input
       if [ $input == "y" ]; then
           docker rm $1
       else
           exit
       fi
    fi
fi

# start bash
docker run $CNAME --privileged -it --device=/dev/ttyACM0 \
  --user=root -v ${PWD}:/working_dir -w /working_dir \
  $IMAGE_NAME \
  /bin/bash
