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

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This scenario simulates a Beacon Flood attack. The script uses mdk4 to broadcast a high volume of fake beacon frames from a list of SSIDs, flooding the wireless spectrum with phantom networks.

This attack runs on the channel the interface is currently set to. It does not require an AP or client, and the goal is to capture the flood of fake management frames."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. AP Profile: $SCN_PROFILE"


confirmation

# ─── Show Capture Config ───
print_section "Capture Preparation"
print_none "Type:          $SCN_CAPTURE"
print_none "BSSID:         $SCN_BSSID"
print_none "Channel:       $SCN_CHANNEL"
print_none "Duration:      $SCN_DURATION seconds"
print_warn "IMPORTANT: A full-spectrum (channel hopping) capture is recommended to ensure the attack is observed."
print_blank
print_action "Launch Capture"

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
timeout "$SCN_DURATION" mdk4 "$INTERFACE" b -f "$SSID_FILE" -s "$SCN_INTERVAL"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0