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

## How to run the containers?

Build the docker image *once* (~4GB in size):

```
./build-docker.sh
```

Run the docker container:

```
./start-docker.sh
```

Note that the start command uses `--rm` flag, thus your container will be 
deleted on exit. Anything modified in `/working_dir` will persist.

### Docker user and root in the container

The docker scripts create a user called `developer`  with your user id.
Running `./build-docker.sh` and `./start-docker.sh` will start a container
with a user that has a matching USER ID to the user that ran the `./build-docker.sh`
script.

This user has root access inside the docker container with the password:
`devpasswd`.

## Compile and run TFLITE 

### Zedboard

Considering that zedboard was setup with the instructions 
[here](https://github.com/tflite-soc/zedboard-setup/tree/master), and it is
accessible under `root@10.42.0.196`, the following steps should work out 
of the box.

```
# (host) Inside tflite-soc folder
./startdocker

# (docker) Enter tensorflow root folder
cd tensorflow

# (docker) Download dependencies
./tensorflow/lite/tools/make/download_dependencies.sh

# (docker) Build the binaries
# Stored at tflite-soc/tensorflow/tensorflow/lite/tools/make/gen/bbb_armv7l
./tensorflow/lite/tools/make/build_bbb_lib.sh

# Copy the binaries to the zedboard
# 1. (docker) Exit the docker container for ssh/scp access
exit

# 2. (host) Copy the cross-compiled binaries to the zedboard
scp -r tensorflow/tensorflow/lite/tools/make/gen/bbb_armv7l/ root@10.42.0.196:~/.

# 3. (host) Copy the models to the zedboard
scp -r tensorflow-models root@10.42.0.196:~/.

# 4. (host) Connect to the zedboard and run the prebuilt TFLITE binaires with a model
ssh root@10.42.0.196

# (zed) List the model
cd 
./bbb_armv7l/bin/minimal tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# (zed) Benchmark the model with 1 thread
./bbb_armv7l/bin/benchmark_model --use_gpu=false --num_threads=1 \
  --enable_op_profiling=true \
  --graph=tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# (zed) Benchmark the model with 2 threads
./bbb_armv7l/bin/benchmark_model --use_gpu=false --num_threads=2 \
  --enable_op_profiling=true \
  --graph=tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite
```
