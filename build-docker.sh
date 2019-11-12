#!/bin/bash

# build-docker.sh

set -e

# get workflow+container name
IMAGE_NAME="mod-nightly-custom-op-ubuntu16"

# build container
docker build -f ./Dockerfile . \
    -t $IMAGE_NAME
