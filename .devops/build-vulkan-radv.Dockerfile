ARG UBUNTU_VERSION=26.04

# ---

FROM ubuntu:$UBUNTU_VERSION AS build

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake git libssl-dev libvulkan-dev glslc glslang-tools

COPY ./llama.cpp /llama.cpp

RUN cmake /llama.cpp -B /llama.cpp/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_RPATH='$ORIGIN' \
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
        -DGGML_BACKEND_DL=ON \
        -DGGML_CPU_ALL_VARIANTS=ON \
        -DGGML_RPC=ON \
        -DGGML_VULKAN=ON \
        -DGGML_CCACHE=OFF \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_EXAMPLES=OFF \
        -DLLAMA_BUILD_TOOLS=ON \
        -DLLAMA_BUILD_SERVER=ON \
    && cmake --build /llama.cpp/build \
        --config Release \
        -j $(nproc) \
    && find /llama.cpp/build/bin \
        -type f \
        -executable \
        -exec strip {} \\;

# ---

FROM ubuntu:$UBUNTU_VERSION AS base

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libgomp1 openssl mesa-vulkan-drivers vulkan-tools \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

# ---

FROM base AS tools

COPY --from=build /llama.cpp/build/bin /app

ENV PATH="$PATH:/app"

CMD ["/bin/bash"]

