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
source "$CONFIG_DIR/t016.conf"

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
"This scenario simulates a Karma attack using a Directed Probe Response. The script uses airbase-ng to listen for clients sending directed probe requests for known SSIDs. When a probe for a target SSID is detected, it sends a spoofed response, tricking the client into connecting to the rogue AP."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. Client device must have previously associated with AP: $SCN_SSID"
print_none "2. Client device must have auto-connect enabled for SSID: $SCN_SSID"
print_none "3. AP profile: $SCN_PROFILE must be offline"
print_blank

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

ensure_monitor_mode
print_blank
print_waiting "Running"
timeout "$SCN_DURATION" airbase-ng -e "$SCN_SSID" -c "$SCN_CHANNEL" -a "$SCN_BSSID" "$INTERFACE"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0