#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_DIR="$SCRIPT_DIR/llama.cpp"
BUILD_DIR="$LLAMA_DIR/build"
DEB_DIR="$BUILD_DIR/deb"
PACKAGE_NAME="llama.cpp"

detect_gpu() {
    local gpu_type="none"
    
    if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
        gpu_type="cuda"
    elif command -v rocminfo &>/dev/null && rocminfo &>/dev/null; then
        gpu_type="rocm"
    elif command -v vulkaninfo &>/dev/null && vulkaninfo 2>/dev/null | grep -q "Vulkan"; then
        gpu_type="vulkan"
    elif system_profiler SPDisplays 2>/dev/null | grep -q "Metal"; then
        gpu_type="metal"
    fi
    
    echo "$gpu_type"
}

main() {
    local raw_arch=$(uname -m)
    local arch
    case "$raw_arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        i386|i686) arch="i386" ;;
        *) arch="$raw_arch" ;;
    esac
    local os=$(lsb_release -is 2>/dev/null || echo "Ubuntu")
    local raw_version=$(git -C "$LLAMA_DIR" describe --tags 2>/dev/null | sed 's/^v//' || git -C "$LLAMA_DIR" rev-parse --short HEAD)
    local version="$raw_version"
    if [[ ! "$version" =~ ^[0-9] ]]; then
        version="0.1.0-$raw_version"
    fi
    local gpu_type
    
    echo "=== System Info ==="
    echo "Architecture: $arch"
    echo "OS: $os"
    
    gpu_type=$(detect_gpu)
    echo "Detected GPU: $gpu_type"
    
    echo "=== Building llama.cpp ==="
    
    mkdir -p "$BUILD_DIR"
    cd "$LLAMA_DIR"
    
    local cmake_opts=(
        -DCMAKE_BUILD_TYPE=Release
        -DLLAMA_BUILD_SERVER=ON
        -DLLAMA_BUILD_CLI=ON
        -DLLAMA_BUILD_STATIC=OFF
        -DGGML_BLAS=ON
        -DGGML_BLAS_VENDOR=OpenBLAS
        -DGGML_NATIVE=ON
    )
    
    case "$gpu_type" in
        cuda)
            cmake_opts+=(-DGGML_CUDA=ON)
            ;;
        rocm)
            cmake_opts+=(-DGGML_HIP=ON -DGGML_AMD_STATIC=OFF)
            ;;
        vulkan)
            cmake_opts+=(-DGGML_VULKAN=ON)
            ;;
        metal)
            cmake_opts+=(-DGGML_METAL=ON)
            ;;
        *)
            echo "No GPU detected, building CPU-only with OpenBLAS"
            ;;
    esac
    
    cmake -B build "${cmake_opts[@]}"
    cmake --build build --config Release -j4
    
    echo "=== Creating Debian package ==="
    
    rm -rf "$DEB_DIR"
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/lib"
    mkdir -p "$DEB_DIR/usr/include/llama.cpp"
    mkdir -p "$DEB_DIR/usr/share/doc/llama.cpp"
    mkdir -p "$DEB_DIR/usr/share/man/man1"
    
    cp build/bin/* "$DEB_DIR/usr/bin/" 2>/dev/null || true
    
    if [ -f "$BUILD_DIR/libllama.so" ]; then
        cp "$BUILD_DIR/libllama.so" "$DEB_DIR/usr/lib/"
    fi
    
    cp -r "$LLAMA_DIR/include/llama.h" "$DEB_DIR/usr/include/llama.cpp/" 2>/dev/null || true
    cp -r "$LLAMA_DIR/ggml/include/ggml.h" "$DEB_DIR/usr/include/llama.cpp/" 2>/dev/null || true
    
    find "$DEB_DIR/usr/bin" -type f -exec chmod 755 {} \;
    
    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $PACKAGE_NAME
Version: $version
Section: utils
Priority: optional
Architecture: $arch
Depends: libc6 (>= 2.31), libopenblas0
Maintainer: llama.cpp
Description: LLM inference library and tools
 Large language model inference library and CLI tools optimized for AMD Ryzen 7 PRO 4750U.
EOF
    
    cat > "$DEB_DIR/DEBIAN/copyright" << EOF
MIT License
Copyright (c) 2023 llama.cpp
EOF
    
    touch "$DEB_DIR/DEBIAN/menufiles"
    touch "$DEB_DIR/usr/share/doc/llama.cpp/copyright"
    
    gzip -c "$LLAMA_DIR/README.md" > "$DEB_DIR/usr/share/doc/llama.cpp/README.gz" 2>/dev/null || true
    
    dpkg-deb --root-owner-group --build "$DEB_DIR" "$SCRIPT_DIR/${PACKAGE_NAME}_${version}_${arch}.deb"
    
    echo "=== Done: $SCRIPT_DIR/${PACKAGE_NAME}_${version}_${arch}.deb ==="
}

main "$@"
