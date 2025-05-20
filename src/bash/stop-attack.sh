#!/bin/bash
# Utility: Stops any running wireless attack launched from WATT
# Usage: ./stop-attack.sh

set -e

# Load helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/print.sh"

# Define known attack processes to kill
ATTACK_PROCESSES=("mdk4" "bettercap" "aireplay-ng")

print_action "Stopping active attack processes"

for proc in "${ATTACK_PROCESSES[@]}"; do
    if pgrep "$proc" > /dev/null; then
        print_action "Killing $proc"
        sudo pkill "$proc"
    else
        print_fail "$proc not running"
    fi
done

# Clear the active attack flag
if [[ -f /tmp/watt_attack_active ]]; then
    print_action "Removing /tmp/watt_attack_active"
    rm -f /tmp/watt_attack_active
else
    print_warn "No active attack flag set"
fi

print_success "Attack environment cleaned"