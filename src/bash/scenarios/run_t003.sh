#!/bin/bash
# ─── T003 SSID Harvesting ───

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

# ─── Helpers ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Simulation ───
print_none "This scenario demonstrates a passive reconnaissance technique where an attacker listens for SSID identifiers in wireless management frames to compile a list of nearby wireless networks.  The goal is to gather network names (SSIDs), BSSIDs, and capabilities that may later support targeted attacks, such as Evil Twin deployment or network profiling.

SSID harvesting is an entirely passive activity, requiring no interaction with client devices or access points."
print_blank

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WSTT full/filtered capture"
print_blank

# ─── Show Params ───
print_section "Simulation Parameters"
print_none "Threat          : $T003_NAME ($T003_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $T003_TOOL"
print_none "Mode            : $T003_MODE"

confirmation

# ─── Show Capture ───
print_section "WSTT Capture Preparation"
print_action "Launch a full/filtered capture using WSTT"
print_none "Duration        : $T003_DURATION seconds"
print_none "Capture Channel : $T003_CHANNEL"

confirmation

# ─── Run Simulation ───
ensure_managed_mode

clear
print_section "Simulation Running"
print_info "You will now launch each AP profile manually on WAPT for $T003_INTERVAL seconds each."

for PROFILE in "${T003_PROFILES[@]}"; do
    PROFILE_NAME="${PROFILE%.cfg}"  # strip .cfg
    confirmation
    print_action "Launch AP profile: $PROFILE_NAME"
    print_waiting "AP profile available for: $T003_INTERVAL seconds"
    sleep "$T003_INTERVAL"
    print_action "Stop AP profile: $PROFILE_NAME"
    sleep "$T003_PAUSE"
done

EXIT_CODE=$?
print_blank

if [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
else
    print_success "Simulation completed"
fi

exit 0