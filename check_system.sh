#!/bin/bash
set -e

install_deps() {
    echo "=== Installing build dependencies ==="
    sudo apt update
    sudo apt install -y \
        build-essential \
        cmake \
        libssl-dev \
        libopenblas-dev \
        libvulkan-dev \
        glslc \
        spirv-headers \
        ocl-icd-opencl-dev \
        opencl-headers \
        clinfo
}

install_cuda() {
    echo "=== Installing CUDA ==="
    sudo apt install -y cuda-toolkit cuda
}

install_rocm() {
    echo "=== Installing ROCm ==="
    sudo apt install -y rocm-dev hipcc
}

main() {
    if [ "$1" = "--install-deps" ]; then
        install_deps
    elif [ "$1" = "--install-cuda" ]; then
        install_cuda
    elif [ "$1" = "--install-rocm" ]; then
        install_rocm
    else
        install_deps
    fi
}

main "$@"
