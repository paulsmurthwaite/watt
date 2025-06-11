#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t001.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Associate with AP ───
ensure_managed_mode
nmcli device wifi connect "$T001_SSID" ifname "$INTERFACE"
print_success "Associated with AP SSID: $T001_SSID"

# ─── Check for IP assignment ───
print_info "Waiting for DHCP lease"
sleep 3
IP_ADDR=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [[ -n "$IP_ADDR" ]]; then
    print_success "DHCP assigned IP: $IP_ADDR"
else
    print_fail "No IP address assigned to $INTERFACE"
    exit 1
fi

# ─── Run Attack ───
print_blank
print_info "Running T001 - Unencrypted Traffic Capture simulation for $T001_DURATION seconds"

sudo timeout "$T001_DURATION" bash $HELPERS_DIR/fn_t001_traffic.sh

EXIT_CODE=$?

# ─── Disassociate from AP ───
print_blank
print_action "Disassociating from AP SSID: $T001_SSID"
nmcli device disconnect "$INTERFACE"
print_success "Disassociated from AP SSID: $T001_SSID"
ensure_managed_mode

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Traffic generation ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "bash exited with code $EXIT_CODE"
fi

exit 0