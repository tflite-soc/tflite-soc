# tflite-soc
Holds scripts to build and start containers that can compile binaries to the zedboard's arm

## Structure

This project includes submodules. Which mirror the subprojects of tflite-soc organization.

In order to clone all submodules, please execute:

```
git clone --recurse-submodules https://github.com/tflite-soc/tflite-soc.git
```

# How to run?

Build the docker image (~4GB in size):

```
./build-docker.sh
```

Run the docker container:

```
./start-docker.sh
```

Note that the start command uses `--rm` flag, thus your container will be deleted on exit.
