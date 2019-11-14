# tflite-soc
Holds scripts to build and start containers that can compile binaries to the zedboard's arm

## Structure

This project includes submodules. Which mirror the subprojects of tflite-soc organization.

In order to clone all submodules, please execute:

```
git clone --recurse-submodules https://github.com/tflite-soc/tflite-soc.git
```

This will produce the following folder structure

```
.
├── benchmarking-models # Contains benchmark results and visualization scripts
├── tensorflow # Clone of the tensorflow project
├── tensorflow-models # Contain links to several DNN models to be benchmarked
└── zedboard-setup # Instructions on how to setup the zedboard to run TFLITE
```

# How to run?

Build the docker image once (~4GB in size):

```
./build-docker.sh
```

Run the docker container:

```
./start-docker.sh
```

Note that the start command uses `--rm` flag, thus your container will be deleted on exit.

## Docker user and root in the container

The docker scripts create a user with your user id.
Running `./build-docker.sh` and `./start-docker.sh` will put you on a container
with a user that has a matching USER ID to the user that ran the `./build-docker.sh`
script.

This user has root access inside the docker container with the password:
`devpasswd`.

## Compile and run TFLITE to the zedboard

```
# Inside tflite-soc folder
./startdocker

# Enter tensorflow root folder
cd tensorflow

# Download dependencies
./tensorflow/lite/tools/make/download_dependencies.sh

# Build the binaries
# Stored at tflite-soc/tensorflow/tensorflow/lite/tools/make/gen/bbb_armv7l
./tensorflow/lite/tools/make/build_bbb_lib.sh

# Copy the binaries to the zedboard
# 1. Exit the docker container for ssh/scp access
exit

# 2. Copy the cross-compiled binaries to the zedboard
scp -r tensorflow/tensorflow/lite/tools/make/gen/bbb_armv7l/ root@10.42.0.196:~/.

# 3. Copy the models to the zedboard
scp -r tensorflow-models root@10.42.0.196:~/.

# 4. Connect to the zedboard and run the prebuilt TFLITE binaires with a model
ssh root@10.42.0.196
cd 

# List the model
./bbb_armv7l/bin/minimal tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# Benchmark the model with 1 thread
./bbb_armv7l/bin/benchmark_model --use_gpu=false --num_threads=1 \
  --enable_op_profiling=true \
  --graph=tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# Benchmark the model with 2 threads
./bbb_armv7l/bin/benchmark_model --use_gpu=false --num_threads=2 \
  --enable_op_profiling=true \
  --graph=tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite



