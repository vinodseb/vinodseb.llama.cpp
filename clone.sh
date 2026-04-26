#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_DIR="$SCRIPT_DIR/llama.cpp"

if [ ! -d "$LLAMA_DIR" ]; then
    echo "=== Cloning llama.cpp repository ==="
    git clone https://github.com/ggerganov/llama.cpp.git "$LLAMA_DIR"
else
    echo "=== llama.cpp already cloned ==="
fi
