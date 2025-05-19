#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Bring interface up
echo "[+] Bringing interface UP."
sudo ip link set $INTERFACE up
sleep 3