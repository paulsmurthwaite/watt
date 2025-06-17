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

# ─── Show Introduction ───
print_none "This scenario demonstrates a passive reconnaissance technique where an attacker listens for SSID identifiers in wireless management frames to compile a list of nearby wireless networks.  The goal is to gather network names (SSIDs), BSSIDs, and capabilities that may later support targeted attacks, such as Evil Twin deployment or network profiling.

SSID harvesting is an entirely passive activity, requiring no interaction with client devices or access points."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat          : $SCN_NAME ($SCN_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $SCN_TOOL"
print_none "Mode            : $SCN_MODE"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full or filtered capture using WSTT"
print_none "Duration        : $SCN_DURATION seconds"
print_none "Capture Channel : $SCN_CHANNEL"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"
print_info "Launch each AP profile manually on WAPT for $SCN_INTERVAL seconds each."

for PROFILE in "${SCN_PROFILES[@]}"; do
    PROFILE_NAME="${PROFILE%.cfg}"  # strip .cfg
    confirmation
    print_action "Launch AP profile: $PROFILE_NAME"
    print_waiting "AP profile available for: $SCN_INTERVAL seconds"
    sleep "$SCN_INTERVAL"
    print_action "Stop AP profile: $PROFILE_NAME"
    sleep "$SCN_PAUSE"
done

EXIT_CODE=$?
print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0