#!/bin/bash
# ─── T006 Misconfigured Access Point ───

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SCENARIO_DIR="$BASH_DIR/scenarios"
SERVICES_DIR="$BASH_DIR/services"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t006.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Simulation ───
print_none "This scenario simulates a wireless access point that has been incorrectly configured by an administrator, leading to weakened security or unintended client exposure.  Misconfigurations can include disabled encryption, fallback to legacy protocols (e.g. WEP), or open SSIDs within a protected environment.

The goal is to demonstrate how such misconfigurations may unintentionally expose sensitive client traffic to attackers monitoring the wireless medium."
print_blank

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WSTT full/filtered capture"
print_blank

# ─── Show Params ───
print_section "Simulation Parameters"
print_none "Threat          : $T006_NAME ($T006_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $T006_TOOL"
print_none "Mode            : $T006_MODE"

confirmation

# ─── Show Capture ───
print_section "WSTT Capture Preparation"
print_action "Launch a full/filtered capture using WSTT"
print_none "Duration        : $T006_DURATION seconds"
print_none "Capture Channel : $T006_CHANNEL"
confirmation

# ─── Run Simulation ───
ensure_managed_mode

clear
print_section "Simulation Running"
print_info "You will now launch AP profile $T006_PROFILE manually on WAPT for $T006_DURATION seconds"

confirmation
print_action "Launch AP profile: $T006_PROFILE"
print_waiting "AP profile available for: $T006_DURATION seconds"
sleep "$T006_DURATION"
print_action "Stop AP profile: $T006_PROFILE"

EXIT_CODE=$?
print_blank

if [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
else
    print_success "Simulation completed"
fi

exit 0