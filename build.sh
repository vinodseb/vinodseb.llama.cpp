#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/clone.sh"
bash "$SCRIPT_DIR/check_system.sh"
bash "$SCRIPT_DIR/build_deb.sh"
