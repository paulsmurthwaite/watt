#!/bin/bash
# ─── T004 Evil Twin Attack ───

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
source "$CONFIG_DIR/ap_t004.cfg"

# ─── Helpers ───
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
print_none "2. The client must have auto-connect enabled for SSID: $T004_SSID"
print_none "3. The genuine AP must be offline or out of range"
print_none "4. WSTT full/filtered capture"
print_blank

# ─── Show Params ───
print_section "Simulation Parameters"
print_none "Threat          : $T004_NAME ($T004_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $T004_TOOL"
print_none "Mode            : $T004_MODE"

confirmation

# ─── Show Capture ───
print_section "WSTT Capture Preparation"
print_action "Launch a full/filtered capture using WSTT"
print_none "Duration        : $T004_DURATION seconds"
print_none "Capture Channel : $T004_CHANNEL"
confirmation

# ─── Start AP ───
clear
print_section "Simulation Started"
print_blank
print_info "Launching Access Point"

bash "$UTILITIES_DIR/start-ap_t004.sh" ap_t004 nat
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Generating Traffic"
    sudo timeout "$T004_DURATION" bash "$HELPERS_DIR/fn_t004_traffic.sh"
fi

# ─── Stop AP ───
print_blank
print_section "Simulation Complete"
print_blank
print_info "Stopping Access Point"

bash "$UTILITIES_DIR/stop-ap.sh"
STOP_EXIT_CODE=$?

if [[ "$STOP_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point shutdown failed (Exit Code: $STOP_EXIT_CODE)"
    exit "$STOP_EXIT_CODE" 
fi

print_success "Simulation completed"

exit 0