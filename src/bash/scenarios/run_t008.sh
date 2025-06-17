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
source "$CONFIG_DIR/t008.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a Beacon Flood attack.  Fake access points are broadcast at high volume to flood the wireless spectrum with phantom SSIDs."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. No real access point is required"
print_none "2. WSTT full or filtered capture is recommended to observe fake SSID broadcasts"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat    : $SCN_NAME ($SCN_ID)"
print_none "Interface : $INTERFACE"
print_none "Tool      : $SCN_TOOL"
print_none "Mode      : $SCN_MODE"
print_none "SSID File : $SCN_SSID_FILE"
print_none "Interval  : $SCN_INTERVAL ms"
print_none "Duration  : $SCN_DURATION seconds"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full capture using WSTT"
print_none "Ensure monitor mode is enabled and no filters are applied"
print_none "Duration  : $SCN_DURATION seconds"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

ensure_monitor_mode
SSID_FILE="$UTILITIES_DIR/$SCN_SSID_FILE"

if [[ -f "$SSID_FILE" ]]; then
    print_blank
    print_info "Using existing SSID list: $SCN_SSID_FILE"
else
    print_blank
    print_action "Generating SSID list: $SCN_SSID_FILE"
    seq -f "SSID-%03g" 1 100 > "$SSID_FILE"
    print_success "Generated 100 SSIDs"
fi

print_blank
print_waiting "Running"
sudo timeout "$SCN_DURATION" mdk4 "$INTERFACE" b -f "$SSID_FILE" -s "$SCN_INTERVAL"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0