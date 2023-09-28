#!/bin/bash

IMAGE_NAME=${IMAGE_NAME:-nvidia-cuda-efa}
IMAGE_BASEE_TAG=${IMAGE_BASEE_TAG:-12.2.0-runtime-ubuntu22.04}
AWS_OFI_NCCL_VER=${AWS_OFI_NCCL_VER:-v1.7.x-aws}

docker run --rm \
       --privileged --gpus all --shm-size=1g \
       -e NCCL_DEBUG=INFO \
       -e NCCL_P2P_DISABLE=1 \
       -e NCCL_NVLS_ENABLE=0 \
       -e NCCL_SHM_DISABLE=1 \
       -e NCCL_NVLS_ENABLE=0 \
       -e NCCL_NET='AWS Libfabric' \
       -e FI_EFA_USE_DEVICE_RDMA=1 \
       -e NCCL_MIN_NCHANNELS=8 \
       ${IMAGE_NAME}:${IMAGE_BASEE_TAG}-efa-${AWS_OFI_NCCL_VER} \
       /opt/nccl-test/all_reduce_perf -g 8 -b 1M -e 1G -f 2
