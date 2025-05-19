#!/bin/bash
# Developer Utility: Stops any running wireless attack launched from WATT
# Usage: ./stop-attack.sh

set -e

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Define known attack processes to kill
ATTACK_PROCESSES=("mdk4" "bettercap" "aireplay-ng")

echo "[*] Stopping active attack processes..."

for proc in "${ATTACK_PROCESSES[@]}"; do
    if pgrep "$proc" > /dev/null; then
        echo "[+] Killing $proc ..."
        sudo pkill "$proc"
    else
        echo "[*] $proc not running."
    fi
done

# Clear the active attack flag
if [[ -f /tmp/watt_attack_active ]]; then
    echo "[+] Removing /tmp/watt_attack_active ..."
    rm -f /tmp/watt_attack_active
else
    echo "[*] No active attack flag set."
fi

echo "[✓] Attack environment cleaned."