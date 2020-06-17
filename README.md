# tflite-soc

Holds scripts to build and start containers that can compile Tensorflow Lite
binaries to the zedboard's arm or build system models for specific TFLite OPs
using SystemC.

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

Build the docker image **once** (~4GB in size):

```
./build-docker.sh
```

Run the docker container:

```
./start-docker.sh
```

Note that the `start` command uses `--rm` flag, thus your container will be 
deleted on exit. Anything modified in `/working_dir` will persist.

### Docker user and root in the container

The docker scripts create a user called `developer`  with your user id.
Running `./build-docker.sh` and `./start-docker.sh` will start a container
with a user that has a matching USER ID to the user that ran the `./build-docker.sh`
script.

This user has root access inside the docker container with the password:
`devpasswd`.

## Compile and run TFLITE 

### For a Zedboard platflorm

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

# (zed) List the model layers
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

### For a x86 platform

All that it is needed is the proper docker setup.
After compilation, binaries will be created in `tensoflow/bazel-bin`

```
# (host) Inside tflite-soc folder
./startdocker

# (docker) Enter tensorflow root folder
cd tensorflow

# (docker) Build the benchmarking and the minimal tools
bazel build tensorflow/lite/tools/benchmark:benchmark_model
bazel build tensorflow/lite/examples/minimal:minimal

# (docker) List the model layers
bazel-bin/tensorflow/lite/examples/minimal/minimal \
    ../tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# (docker) Benchmark the model with 1 thread
bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model \
    --use_gpu=false --num_threads=1 \
    --enable_op_profiling=true \
    --graph=../tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite

# (docker) Benchmark the model with 4 threads
bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model \
    --use_gpu=false --num_threads=4 \
    --enable_op_profiling=true \
    --graph=../tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite
```

## Compile and run TFLITE with SystemC

### For a x86 platform

```
# (host) Inside tflite-soc folder
./startdocker

# (docker) Enter tensorflow root folder
cd tensorflow

# (docker) Verify that you are on the system-c branch on submodule
git fetch origin system-c
git checkout system-c

# -- Commands to build SystemC models --

# Hello World example
bazel build --jobs 1 //tensorflow/lite/examples/systemc:hello_systemc
bazel run //tensorflow/lite/examples/systemc:hello_systemc

# Channel with producer consumer example
bazel build --jobs 1 //tensorflow/lite/examples/systemc:hello_channel
bazel run //tensorflow/lite/examples/systemc:hello_channel

# SystemC with integrated GTest Suite for TDD
bazel build --jobs 1 //tensorflow/lite/examples/systemc:sc_example_test
bazel test //tensorflow/lite/examples/systemc:sc_example_test

# 2D Systolic array accelerator in isolation
bazel build --jobs 1 //tensorflow/lite/kernels/modeling:systolic_run
bazel run //tensorflow/lite/kernels/modeling:systolic_run

# 2D Systolic array accelerator with TFLite benchmarking tools
bazel build --jobs 1 //tensorflow/lite/examples/systemc:hello_channel # SeeBugs
bazel build //tensorflow/lite/tools/benchmark:benchmark_model --cxxopt=-DTOGGLE_TFLITE_SOC=1
bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model \
    --use_gpu=false --num_threads=1 --enable_op_profiling=true \
    --graph=../tensorflow-models/mobilenet-v1/mobilenet_v1_1.0_224_quant.tflite \
    --num_runs=1
```

# Known BUGs

1) SystemC dependent binaries fail to build
  * Because of a bug in bazel's build system when executing command line
    arguments that take too long, aka building SystemC lib, SystemC may not be
    ready. To prevent it, compile with --jobs 1 flag

# LICENSE Note

This repository is licensed under the [Apache License 2.0](LICENSE)

However, this repository includes other repositories as submodules and they
may have their own individual licenses. Please check the submodules licenses
accordingly.
