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

FROM tensorflow/tensorflow:nightly-custom-op-ubuntu16
#FROM tensorflow/tensorflow:latest-devel-py3

RUN apt update

# Development Tools
RUN apt install -y curl
RUN apt install -y wget
RUN apt install -y tree
RUN apt install -y less

RUN apt install -y git

RUN apt install -y vim
RUN apt install -y tmux

# Requirements for VSCODE plugins
WORkDIR /usr/local/bin
wget -q https://github.com/bazelbuild/buildtools/releases/download/3.2.1/buildifier -O buildifier

# Tools to cross-compile for the Zedboard
RUN apt install -y minicom
RUN apt install -y crossbuild-essential-armhfA

# Tools to profile x86 code 
# RUN apt install -y perf

# WORKDIR /root
# RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.5/cmake-3.13.5-Linux-x86_64.sh && \
#     chmod +x cmake-3.13.5-Linux-x86_64.sh && \
#     ./cmake-3.13.5-Linux-x86_64.sh --skip-license --prefix=/usr
# 
# # Clone flame graphs for profiling
# WORKDIR /root/src
# RUN git clone https://github.com/brendangregg/FlameGraph

# Setup some convenient tools/functionalities
WORKDIR /root
RUN git clone https://github.com/agostini01/dotfiles.git && \
    \
    ln -sf dotfiles/.gitignore_global .gitignore_global && \
    \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    \
    ln -sf dotfiles/.vimrc            .vimrc && \
    ln -sf dotfiles/.ctags            .ctags && \
    ln -sf dotfiles/.inputrc          .inputrc && \
    \
    git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm && \
    ln -sf dotfiles/.tmux.conf        .tmux.conf

RUN echo "PS1='\[\033[01;31m\][\[\033[01;30m\]\u@\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '" >> .bashrc


# Print welcome message
RUN echo "echo 'Welcome to tensorflow custom-op-arm-ubuntu16'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc && \
    echo "echo 'To connect to the zedboard over tty:'" >> ~/.bashrc && \
    echo "echo '    minicom -D /dev/ttyACM0 -b 115200 -8 -o'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc 


# ============================================================================
# Add dev user with matching UID of the user who build the image
ARG USER_ID
ARG GROUP_ID
RUN useradd -m --uid $USER_ID developer && \
    echo "developer:devpasswd" | chpasswd && \
    usermod -aG dialout developer && \
    usermod -aG sudo developer

USER developer
WORKDIR /home/developer
RUN git clone https://github.com/agostini01/dotfiles.git && \
    \
    ln -sf dotfiles/.gitignore_global .gitignore_global && \
    \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    \
    ln -sf dotfiles/.vimrc            .vimrc && \
    ln -sf dotfiles/.ctags            .ctags && \
    ln -sf dotfiles/.inputrc          .inputrc && \
    \
    git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm && \
    ln -sf dotfiles/.tmux.conf        .tmux.conf

RUN echo "PS1='\[\033[01;31m\][\[\033[01;30m\]\u@\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '" >> .bashrc

# Print welcome message
RUN echo "echo 'Welcome to tensorflow custom-op-arm-ubuntu16'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc && \
    echo "echo 'To connect to the zedboard over tty:'" >> ~/.bashrc && \
    echo "echo '    minicom -D /dev/ttyACM0 -b 115200 -8 -o'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc 

# Change to the correct directory
WORKDIR  /
