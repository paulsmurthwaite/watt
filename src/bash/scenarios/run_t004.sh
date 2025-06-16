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
source "$CONFIG_DIR/t004.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Simulation ───
print_none "This scenario simulates an attacker broadcasting a rogue access point with the same SSID and BSSID as a genuine Wi-Fi network in order to device client devices into associating with it.  The goal is to exploit auto-connect behaviour or signal preferences logic in client devices.

Once connected, clients may transmit sensitive information such as:

- cleartext HTTP credentials
- DNS queries
- Session cookies
- Any unencrypted service traffic

The scenario forms the basis for further exploration such as captive portal spoofing, man-in-the-middle attacks, or credential harvesting."
print_blank

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. A client device must have previously connected to the genuine AP"
print_none "2. The client must have auto-connect enabled for SSID: $SCN_SSID"
print_none "3. The genuine AP must be offline or out of range"
print_none "4. WSTT full/filtered capture"
print_blank

# ─── Show Params ───
print_section "Simulation Parameters"
print_none "Threat          : $SCN_NAME ($SCN_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $SCN_TOOL"
print_none "Mode            : $SCN_MODE"

confirmation

# ─── Show Capture ───
print_section "WSTT Capture Preparation"
print_action "Launch a full/filtered capture using WSTT"
print_none "Duration        : $SCN_DURATION seconds"
print_none "Capture Channel : $SCN_CHANNEL"
confirmation

# ─── Run Simulation ───
clear
print_section "Simulation Running"

# ─── Start AP ───
print_info "Launching Access Point"

bash "$UTILITIES_DIR/start-ap_t004.sh" ap_t004 nat
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Generating Traffic"
    sudo timeout "$SCN_DURATION" bash "$HELPERS_DIR/fn_traffic.sh" t004
    print_blank
fi

# ─── Stop AP ───
print_info "Stopping Access Point"

bash "$UTILITIES_DIR/stop-ap.sh"
STOP_EXIT_CODE=$?

print_blank

if (( STOP_EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $STOP_EXIT_CODE)"
fi

exit 0