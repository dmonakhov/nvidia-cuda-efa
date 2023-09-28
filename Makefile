IMAGE_NAME ?= nvidia-cuda-efa
IMAGE_BASEE_TAG  ?= 12.2.0-runtime-ubuntu22.04
AWS_OFI_NCCL_VER ?= v1.7.x-aws

build:
	docker build --tag "${IMAGE_NAME}:${IMAGE_BASEE_TAG}-efa-${AWS_OFI_NCCL_VER}" .
