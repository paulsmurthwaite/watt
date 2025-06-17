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
source "$CONFIG_DIR/t016.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a spoofed access point responding to directed probe requests from client devices.  This emulates the behaviour of known Wi-Fi networks being impersonated, aiming to trick clients into initiating an auto-connect sequence."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. Client device must have previously connected to a known SSID (e.g. WSTTCorpWiFi)"
print_none "2. Shut down the original access point using that SSID before running the attack"
print_none "3. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat     : $SCN_NAME ($SCN_ID)"
print_none "Interface  : $INTERFACE"
print_none "Tool       : $SCN_TOOL"
print_none "Mode       : $SCN_MODE"

confirmation

# ─── Show AP Config ───
print_section "Access Point & Client Preparation"
print_action "Launch a Spoofed SSID Access Point and associate a client device then shutdown the Spoofed SSID Access Point"
print_none "SSID    : $SCN_SSID"
print_none "BSSID   : $SCN_BSSID"
print_none "Channel : $SCN_CHANNEL"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full or filtered capture using WSTT"
print_none "BSSID      : $SCN_BSSID"
print_none "Channel    : $SCN_CHANNEL"
print_none "Duration   : $SCN_DURATION seconds"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

ensure_monitor_mode
print_blank
print_waiting "Running"
sudo timeout "$SCN_DURATION" airbase-ng -e "$SCN_SSID" -c "$SCN_CHANNEL" -a "$SCN_BSSID" "$INTERFACE"
EXIT_CODE=$?
ensure_managed_mode

print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0