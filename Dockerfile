# syntax=docker/dockerfile:1

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04
ARG AWS_OFI_NCCL_VER=v1.7.3-aws
ARG AWS_EFA_INSTALLER_VER=1.27.0
ARG CUDA_HOME=/usr/local/cuda-12.2
ARG BDIR=/tmp/bld
#ARG NCCL_VER=2.19.3+cuda12.3
ARG NCCL_VER=2.18.5-1+cuda12.2

RUN apt-get update -y && \
    apt-get install -y \
	    libhwloc-dev \
	    libtool \
	    autoconf \
	    libnccl2=$NCCL_VER \
	    libnccl-dev=$NCCL_VER \
	    curl \
	    git \
	    make \
	    openssh-server && \
    mkdir $BDIR && \
    cd $BDIR && \
    curl -sL https://efa-installer.amazonaws.com/aws-efa-installer-${AWS_EFA_INSTALLER_VER}.tar.gz | tar zx && \
    cd aws-efa-installer && \
    ./efa_installer.sh -k -y -n && \
    echo /opt/amazon/openmpi/lib > /etc/ld.so.conf.d/openmpi.conf && \
    \
    git clone https://github.com/NVIDIA/nccl-tests.git && \
    cd nccl-tests && \
    make -j MPI=1 MPI_HOME=/opt/amazon/openmpi CUDA_HOME=/usr/local/cuda && \
    mv build /opt/nccl-test && \
    cd .. && \
    \
    git clone https://github.com/aws/aws-ofi-nccl && \
    cd aws-ofi-nccl && \
    git reset --hard ${AWS_OFI_NCCL_VER} && \
    ./autogen.sh  && \
    ./configure --with-libfabric=/opt/amazon/efa \
		--with-cuda=/usr/local/cuda \
		--with-mpi=/opt/amazon/openmpi \
		--enable-platform-aws \
		--prefix ${CUDA_HOME}/efa && \
    make -j && make install && \
    echo /usr/local/cuda/efa/lib > /etc/ld.so.conf.d/aws-ofi-nccl.conf && \
    cd / && \
    rm -rf $BDIR && \
    apt-get remove -y libhwloc-dev libtool autoconf curl make git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
       /usr/share/doc /usr/share/doc-base \
       /usr/share/man /usr/share/locale /usr/share/zoneinfo

MAINTAINER Monakhov Dmitry monakhov@amazon.com
