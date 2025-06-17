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
source "$CONFIG_DIR/t003.conf"

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
"This scenario demonstrates a passive reconnaissance technique where an attacker listens for SSID identifiers in wireless management frames to compile a list of nearby wireless networks.  The goal is to gather network names (SSIDs), BSSIDs, and capabilities that may later support targeted attacks, such as Evil Twin deployment or network profiling.

SSID harvesting is an entirely passive activity, requiring no interaction with client devices or access points."
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
print_blank
print_action "Launch Capture"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"
print_info "Launch each AP profile manually on WAPT for $SCN_INTERVAL seconds each."
print_blank

for PROFILE in "${SCN_PROFILES[@]}"; do
    PROFILE_NAME="${PROFILE%.cfg}"  # strip .cfg
    print_action "Launch AP profile: $PROFILE_NAME"
    print_waiting "AP profile available for: $SCN_INTERVAL seconds"
    sleep "$SCN_INTERVAL"
    print_action "Stop AP profile: $PROFILE_NAME"
    sleep "$SCN_PAUSE"
    confirmation
done

EXIT_CODE=$?
print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0