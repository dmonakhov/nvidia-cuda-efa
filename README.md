# nvidia-cuda-efa
Nvidia/cuda docker image with EFA support
# Build
```
docker build  --tag=nvidia-cuda-efa .
```

# Run selftest on single  instance
```
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
       nvidia-cuda-efa \
       /opt/nccl-test/all_reduce_perf -g 8 -b 1M -e 1G -f 2
```
