FROM ubuntu:26.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git build-essential cmake ninja-build npm libssl-dev \
        ocl-icd-opencl-dev \
        libvulkan-dev spirv-headers glslc glslang-tools \
    && apt-get autoremove --purge -y \
    && apt-get clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

