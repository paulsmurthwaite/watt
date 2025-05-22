#!/bin/bash
# Utility: Stops any running wireless attack launched from WATT
# Usage: ./stop-attack.sh

set -e

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/atk_airbase_probe.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"

print_action "Stopping active attack processes"

for proc in "${ATK_PROCESSES[@]}"; do
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