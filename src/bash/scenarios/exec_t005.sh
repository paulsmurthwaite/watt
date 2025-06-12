#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t005.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Start AP ───
print_section "Simulation Started"
print_blank
print_info "Launching Access Point"

bash "$UTILITIES_DIR/start-ap_t005.sh" ap_rogue_t005 nat
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Generating Traffic"
    sudo timeout "$T005_DURATION" bash $HELPERS_DIR/fn_t005_traffic.sh
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

exit 0