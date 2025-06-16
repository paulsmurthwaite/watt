#!/bin/bash
# ─── T003 Open Rogue AP ───

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SCENARIO_DIR="$BASH_DIR/scenarios"
SERVICES_DIR="$BASH_DIR/services"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t005.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Simulation ───
print_none "Objective: This scenario simluates an attacker deploying an unauthorised, open Wi-Fi access point in a trusted network environment.  The goal is to lure unsuspecitng users to connect, thereby enabled passive traffic observation or active manipulation (e.g. DNS spoofing, phishing pages, or data capture).

Unlike Evil Twin attacks, this rogue AP does not impersonate a known SSID - it presents a new, legitimate-looking network name (e.g. "Guest_WiFi" or "FreePublicWiFi") designed to attract users."
print_blank

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. T005: WPA2 AP profile (WSTT-T005-WPA2) must be active"
print_none "2. T005: Rogue access point (WSTT-T005-Guest) will be launched"
print_none "3. WSTT full/filtered capture must be started before simulation begins"
print_blank

# ─── Show Params ───
print_section "Simulation Parameters"
print_none "Threat          : $T005_NAME ($T005_ID)"
print_none "Interface       : $INTERFACE"
print_none "Tool            : $T005_TOOL"
print_none "Mode            : $T005_MODE"

confirmation

# ─── Show AP/Client config ───
print_section "Access Point & Client Preparation"
print_none "1. Launch AP profile $T005_WAPT on WAPT"
print_none "2. Prepare a client device to join the Rogue AP SSID: $T005_ROGUE_SSID"

confirmation

# ─── Show Capture ───
print_section "WSTT Capture Preparation"
print_action "Launch a full/filtered capture using WSTT"
print_none "Duration        : $T005_DURATION seconds"
print_none "Capture Channel : $T005_CHANNEL"

confirmation

# ─── Run Simulation ───
ensure_managed_mode

clear
print_section "Simulation Running"

# ─── Start AP ───
bash "$UTILITIES_DIR/start-ap_t005.sh" ap_t005 nat
START_EXIT_CODE=$?

if [[ "$START_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point launch failed"
    exit "$START_EXIT_CODE"
else
    print_success "Access Point launch successful"
    print_info "Generating Traffic"  # Generate network traffic
    sudo timeout "$T005_DURATION" bash $HELPERS_DIR/fn_t005_traffic.sh
fi

# ─── Stop AP ───
print_blank
print_section "Simulation Complete"
print_info "Stopping Access Point"

bash "$UTILITIES_DIR/stop-ap.sh"
STOP_EXIT_CODE=$?
print_blank

if [[ "$STOP_EXIT_CODE" -ne 0 ]]; then
    print_fail "Access Point shutdown failed (Exit Code: $STOP_EXIT_CODE)"
    exit "$STOP_EXIT_CODE" 
fi

print_success "Simulation completed"

exit 0