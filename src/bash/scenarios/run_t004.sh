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

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This scenario simulates an attacker broadcasting a rogue access point with the same SSID and BSSID as a genuine Wi-Fi network in order to device client devices into associating with it.  The goal is to exploit auto-connect behaviour or signal preferences logic in client devices.

Once connected, clients may transmit sensitive information such as:

1. Clear text HTTP credentials
2. DNS queries
3. Session cookies
4. Any unencrypted service traffic

The scenario forms the basis for further exploration such as captive portal spoofing, man-in-the-middle attacks, or credential harvesting."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. Client device must have previously associated with AP: $SCN_SSID"
print_none "2. Client device must have auto-connect enabled for SSID: $SCN_SSID"
print_none "3. AP profile: $SCN_PROFILE must be offline"


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

# ─── Start AP ───
bash "$HELPERS_DIR/fn_start-ap.sh" t004
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

bash "$HELPERS_DIR/fn_stop-ap.sh"
EXIT_CODE=$?

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0