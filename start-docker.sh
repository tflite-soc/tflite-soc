#!/bin/bash
# ==============================================================================
# Copyright 2020 The TFLITE-SOC Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

set -e

USER_ID=$(id -u)

IMAGE_NAME="mod-nightly-custom-op-ubuntu16-user-$USER_ID"

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
  --user=$USER_ID \
  -v ${PWD}:/working_dir -w /working_dir \
  $IMAGE_NAME \
  /bin/bash
