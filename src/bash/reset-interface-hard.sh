#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Read interface driver
DRIVER=$(basename "$(readlink /sys/class/net/$INTERFACE/device/driver)")

# Remove interface driver
echo "[+] Unloading interface $INTERFACE driver $DRIVER ..."
sudo rmmod $DRIVER

# Reload interface driver
echo "[+] Reloading interface $INTERFACE ..."
sudo modprobe $DRIVER
sleep 5