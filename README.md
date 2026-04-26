# vinodseb.llama.cpp

Automated build scripts to compile `llama.cpp` and package it as a Debian (.deb) installer.

## Features

- **Automated Workflow**: One-click build from cloning to packaging.
- **GPU Auto-Detection**: Automatically detects and configures builds for CUDA, ROCm, Vulkan, or Metal.
- **Debian Packaging**: Creates a `.deb` package for easy deployment on Ubuntu/Debian systems.
- **Multi-Arch Support**: Supports `amd64` and `arm64` architectures.

## Project Structure

- `build.sh`: The main orchestrator script. Run this to start the entire process.
- `clone.sh`: Handles cloning the official `llama.cpp` repository.
- `check_system.sh`: Detects system architecture and installs required build dependencies via `apt`.
- `build_deb.sh`: Compiles the source code and packages the binaries into a Debian installer.

## Getting Started

### Prerequisites

Ensure you have `sudo` privileges on your Ubuntu/Debian system.

### Quick Start

Run the master build script:

```bash
chmod +x build.sh
./build.sh
```

### Manual Steps

If you prefer to run the stages individually:

1. **Clone the source**:
   ```bash
   ./clone.sh
   ```

2. **Prepare the system**:
   ```bash
   ./check_system.sh
   ```

3. **Build and Package**:
   ```bash
   ./build_deb.sh
   ```

## Build Details

The scripts configure `llama.cpp` with the following defaults:
- `CMAKE_BUILD_TYPE=Release`
- `LLAMA_BUILD_SERVER=ON`
- `LLAMA_BUILD_CLI=ON`
- `DGGML_BLAS=ON` (OpenBLAS)

## License

This project is licensed under the MIT License.
