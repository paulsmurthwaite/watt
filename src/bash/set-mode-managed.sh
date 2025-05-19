#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Change mode
echo "[+] Setting Managed mode."
bash "$SCRIPT_DIR/set-interface-down.sh"  # Interface down
sudo iw dev $INTERFACE set type managed
bash "$SCRIPT_DIR/set-interface-up.sh"  # Interface up