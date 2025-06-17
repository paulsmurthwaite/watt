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
source "$CONFIG_DIR/t015.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a rogue open access point that broadcasts a known SSID in order to trick client devices into automatically connecting.  This takes advantage of auto-connect behaviour for open networks stored in the client's known networks list."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. Client device must have previously connected to a known SSID (e.g. WSTTCorpWiFi)"
print_none "2. Shut down the original access point using that SSID before running the attack"
print_none "3. WSTT full/filtered capture"
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
print_action "Launch Access Point and associate a client device then shutdown the Access Point"
print_none "SSID      : $SCN_SSID"
print_none "BSSID     : $SCN_BSSID"
print_none "Channel   : $SCN_CHANNEL"

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

# ─── Start AP ───
bash "$HELPERS_DIR/fn_start-ap.sh" t015
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Generating Traffic"
    sudo timeout "$SCN_DURATION" bash "$HELPERS_DIR/fn_traffic.sh" t015
    print_blank
fi

# ─── Stop AP ───
print_info "Stopping Access Point"

bash "$HELPERS_DIR/fn_stop-ap.sh"
EXIT_CODE=$?

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0