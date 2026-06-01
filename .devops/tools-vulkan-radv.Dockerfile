FROM ghcr.io/ezforever/llama.cpp-builds:base-build AS build

COPY ./llama.cpp /llama.cpp

RUN cmake /llama.cpp -G Ninja -B /llama.cpp/build \
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
        -exec strip {} ';'

# ---

FROM ghcr.io/ezforever/llama.cpp-builds:base-vulkan-radv AS target

COPY --from=build /llama.cpp/build/bin /app

ENV PATH="$PATH:/app"

CMD ["/bin/bash"]

