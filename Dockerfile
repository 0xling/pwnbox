FROM ubuntu:18.04
MAINTAINER Ling <ling_pro@163.com>

RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

RUN  apt-get clean

# Apt packages
RUN dpkg --add-architecture i386  && apt update

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
        binutils-powerpc64-linux-gnu \
        tmux ipython3

#RUN pip install --upgrade "pip < 21.0"
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U pip
RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
RUN pip config set install.trusted-host mirrors.aliyun.com

RUN pip install pwntools --ignore-installed
RUN pip install zio uncompyle6 termcolor ropgadget keystone-engine pycryptodome
#RUN pip3 install --upgrade "pip < 21.0"
RUN pip3 install --upgrade pip
RUN pip3 install cryptography==2.5
RUN pip3 install thefuck zio setuptools-rust keystone-engine pycryptodome
RUN pip3 install pwntools --ignore-installed

RUN gem sources --remove https://rubygems.org/ && gem sources -a http://gems.ruby-china.com/
RUN gem install one_gadget seccomp-tools

RUN git clone https://github.com/longld/peda.git ~/peda --depth=1
RUN git clone https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb --depth=1
RUN touch /.dockerenv
RUN git clone https://github.com/pwndbg/pwndbg.git ~/pwndbg --depth=1
RUN git clone https://github.com/hugsy/gef.git ~/gef --depth=1
RUN git clone https://github.com/alset0326/peda-arm.git ~/peda-arm --depth=1
RUN cd ~/pwndbg && ./setup.sh

RUN cd ~ && git clone https://github.com/gpakosz/.tmux.git --depth=1 && ln -s -f .tmux/.tmux.conf

RUN cd ~ && git clone https://github.com/soaringk/gdb-peda-pwndbg-gef.git && cd ~/gdb-peda-pwndbg-gef 
#RUN cp gdb-peda /usr/bin/gdb-peda && cp gdb-peda-arm /usr/bin/gdb-peda-arm && \
#    cp gdb-peda-intel /usr/bin/gdb-peda-intel && cp gdb-pwndbg /usr/bin/gdb-pwndbg && \
#    cp gdb-gef /usr/bin/gdb-gef && chmod +x /usr/bin/gdb-*


#oh my zsh
ADD zsh_install.sh /ctf/
RUN sh /ctf/zsh_install.sh

RUN cd ~/gdb-peda-pwndbg-gef && cp gdb-peda /usr/bin/gdb-peda && \
    cp gdb-pwndbg /usr/bin/gdb-pwndbg && \
    cp gdb-gef /usr/bin/gdb-gef && chmod +x /usr/bin/gdb-*

RUN git clone https://gitclone.com/github.com/0xling/patchelf.git ~/patchelf --depth=1 && cd ~/patchelf && \
    ./bootstrap.sh && ./configure && make && make install

#RUN pip3 install frida
RUN apt install -y libreadline-dev autojump psmisc
RUN pip install pcappy

RUN rm -rf /tmp/* /var/tmp/*
COPY vimrc /root/.vimrc
COPY gdbinit /root/.gdbinit
COPY tmux.conf.local /root/.tmux.conf.local
COPY pwn_template.py /root/pwn_template.py
RUN ln -s /usr/local/lib/python2.7/dist-packages/pwnlib/constants ~/constants

RUN echo "eval \$(thefuck --alias)" >> ~/.zshrc
RUN echo ". /usr/share/autojump/autojump.sh" >> ~/.zshrc
ENV LANG C.UTF-8
WORKDIR /ctf
CMD ["/bin/bash"]
