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
