#!/bin/bash

# build-docker.sh

set -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)

# get workflow+container name
IMAGE_NAME="mod-nightly-custom-op-ubuntu16-user-$USER_ID"

# build container
docker build -f ./Dockerfile . \
    -t $IMAGE_NAME \
    --build-arg USER_ID=$USER_ID \
    --build-arg GROUP_ID=$GROUP_ID 
