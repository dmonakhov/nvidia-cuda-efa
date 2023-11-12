IMAGE_NAME ?= nvidia-cuda-efa
IMAGE_BASE_TAG  ?= 12.1.0-runtime-ubuntu22.04
AWS_OFI_NCCL_VER ?= v1.7.3-aws
EXPORT_PATH ?= /fsx/ct-img

ENROOT_SQUASH_OPTIONS ?= -comp lzo
CT_RUNTIME ?= dockerd://
TAG=${IMAGE_BASE_TAG}-efa-${AWS_OFI_NCCL_VER}

build:
	docker build --rm \
		--tag "${IMAGE_NAME}:${TAG}" \
		--build-arg AWS_OFI_NCCL_VER="${AWS_OFI_NCCL_VER}" .

tar-img: build
	docker save "${IMAGE_NAME}:${TAG}"  | \
		zstdmt -v --ultra -21 -f -o ${EXPORT_PATH}/${IMAGE_NAME}-${TAG}.tar.zst

enroot-img: build
	ENROOT_SQUASH_OPTIONS="${ENROOT_SQUASH_OPTIONS}" \
		enroot import -o ${EXPORT_PATH}/${IMAGE_NAME}+${TAG}.sqsh ${CT_RUNTIME}${IMAGE_NAME}:${TAG}
