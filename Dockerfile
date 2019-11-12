FROM tensorflow/tensorflow:nightly-custom-op-ubuntu16
#FROM tensorflow/tensorflow:latest-devel-py3

RUN apt update

# Development Tools
RUN apt install -y curl
RUN apt install -y wget
RUN apt install -y tree

RUN apt install -y git

RUN apt install -y vim
RUN apt install -y tmux

# Tools to cross-compile for the Zedboard
RUN apt install -y minicom
RUN apt install -y crossbuild-essential-armhf

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

# Clonning the interesting projects


RUN echo "echo 'Welcome to tensorflow custom-op-arm-ubuntu16'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc && \
    echo "echo 'To connect to the zedboard over tty:'" >> ~/.bashrc && \
    echo "echo '    minicom -D /dev/ttyACM0 -b 115200 -8 -o'" >> ~/.bashrc && \
    echo "echo ' '" >> ~/.bashrc 
    
# Change to the correct directory
WORKDIR  /
