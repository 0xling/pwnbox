FROM ubuntu:18.04
MAINTAINER Ling <ling_pro@163.com>

RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list


ENV DEBIAN_FRONTEND=noninteractive

RUN  apt-get clean

# Apt packages
RUN dpkg --add-architecture i386 && apt update

RUN apt install -y apt-utils git nasm python build-essential python-dev \
        python-pip python-setuptools python3-dev python3-pip \
        gcc-multilib  gcc g++ gdb-multiarch wget curl \
        glibc-source cmake lib32z1 \
        python-capstone socat netcat ruby ruby-dev \
        ipython autoconf nmap unzip upx \
        libseccomp-dev libssl-dev libffi-dev libglib2.0-dev \
        libc6:i386 libc6-dbg libc6-dbg:i386 libncurses5:i386 \
        libstdc++6:i386 libc6-dev-i386 libjpeg-turbo8-dev ltrace strace \
        binutils file rpm2cpio cpio zstd \ 
        vim net-tools inetutils-ping silversearcher-ag \
        qemu-user-static zsh bison flex \
        binutils-aarch64-linux-gnu \
        binutils-arm-linux-gnueabihf \
        binutils-mips-linux-gnu \
        binutils-mips64-linux-gnuabi64 \
        binutils-mips64el-linux-gnuabi64 \
        binutils-mipsel-linux-gnu \
        binutils-powerpc-linux-gnu \
        binutils-powerpc64-linux-gnu

#RUN pip install --upgrade "pip < 21.0"
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U pip
RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
RUN pip config set install.trusted-host mirrors.aliyun.com

RUN pip install pwntools --ignore-installed
RUN pip install zio uncompyle6 termcolor ropgadget
#RUN pip3 install --upgrade "pip < 21.0"
RUN pip3 install thefuck

RUN gem install one_gadget seccomp-tools

RUN git clone https://github.com/longld/peda.git ~/peda --depth=1
RUN cd ~ && git clone https://github.com/scwuaptx/Pwngdb.git --depth=1 && cp ~/Pwngdb/.gdbinit ~/

#oh my zsh
ADD install.sh /ctf/
RUN sh /ctf/install.sh

RUN rm -rf /tmp/* /var/tmp/*
COPY ./vimrc ~/.vimrc
RUN echo "eval \$(thefuck --alias)" >> ~/.zshrc
ENV LANG C.UTF-8
WORKDIR /ctf
CMD ["/bin/bash"]
