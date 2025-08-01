#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SCENARIO_DIR="$BASH_DIR/scenarios"
SERVICES_DIR="$BASH_DIR/services"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t001.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"Simulates an attacker broadcasting a rogue access point with the same SSID and BSSID as a genuine AP to trick clients into associating automatically and leaking sensitive traffic."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. AP Profile: $SCN_PROFILE"
print_blank

# ─── Show AP Config ───
print_section "Access Point Preparation"
print_none "AP Profile:    $SCN_PROFILE"
print_none "SSID:          $SCN_SSID"
print_none "BSSID:         $SCN_BSSID"
print_none "Channel:       $SCN_CHANNEL"
print_blank
print_action "Launch Access Point"

confirmation

# ─── Show Capture Config ───
print_section "Capture Preparation"
print_none "Type:          $SCN_CAPTURE"
print_none "BSSID:         $SCN_BSSID"
print_none "Channel:       $SCN_CHANNEL"
print_none "Duration:      $SCN_DURATION seconds"
print_blank
print_action "Launch Capture"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

# ─── Associate with AP ───
print_action "Associating with AP SSID: $SCN_SSID"
ensure_managed_mode
nmcli device wifi connect "$SCN_SSID" ifname "$INTERFACE"
print_success "Associated with AP SSID: $SCN_SSID"
print_blank

# ─── Check for IP assignment ───
print_info "Waiting for DHCP lease"
sleep 3
IP_ADDR=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [[ -n "$IP_ADDR" ]]; then
    print_success "DHCP assigned IP: $IP_ADDR"
    print_blank
else
    print_fail "No IP address assigned to $INTERFACE"
    exit 1
fi

# ─── Generate Traffic ───
print_info "Running $SCN_ID - $SCN_NAME simulation for $SCN_DURATION seconds"
timeout "$SCN_DURATION" bash "$HELPERS_DIR/fn_traffic.sh" t001
print_blank
EXIT_CODE=$?

# ─── Disassociate from AP ───
print_action "Disassociating from AP SSID: $SCN_SSID"
nmcli device disconnect "$INTERFACE"
print_success "Disassociated from AP SSID: $SCN_SSID"
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0