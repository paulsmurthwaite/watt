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
source "$CONFIG_DIR/t005.conf"

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
"This script launches an unauthorised, open Wi-Fi access point. The goal is to lure unsuspecting users to connect, enabling traffic observation or further attacks.

This script can be used as part of a larger scenario where a legitimate network is taken down, and this rogue AP is brought up to attract disconnected clients."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. An external client device is required to connect to the Rogue AP after it is launched."
print_none "2. The WSTT capture should be running before this script is started."
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

# ─── Start AP ───
bash "$HELPERS_DIR/fn_start-ap.sh" t005
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Waiting for capture duration ($SCN_DURATION seconds)..."
    # Wait for the configured duration to allow for external client connection and traffic capture.
    sleep "$SCN_DURATION"
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