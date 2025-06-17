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
source "$CONFIG_DIR/t002.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── FN: Simulate Directed Probe Requests ───
simulate_probe_requests() {
    START_TIME=$(date +%s)

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        if (( ELAPSED >= SCN_DURATION )); then
            break
        fi

        # ─── Probes ───
        for SSID in "${SCN_SSIDS[@]}"; do
            print_action "Probing for SSID: $SSID"
            nmcli device wifi connect "$SSID" ifname "$INTERFACE" >/dev/null 2>&1 || true
            nmcli device disconnect "$INTERFACE" >/dev/null 2>&1
            sleep "$SCN_INTERVAL"
        done
    done
}

# ─── Show Introduction ───
print_none "Objective: This scenario demonstrates the ability of a passive attacker to capture wireless probe request frames transmitted by client devices.  These frames are sent when clients actively search for known Wi-Fi networks (SSIDs), often revealing previous connection history and preferred network names.

The attacker listens silently on the wireless channel to capture these requests.  This can be used to:

- profile a user's historical locations or home/office networks
- identify targets for directed attacks (e.g. Evil Twin or Directed Probe Response)
- correlate device behaviour with unique identifiers (e.g. MAC addresses)"

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat     : $SCN_NAME ($SCN_ID)"
print_none "Interface  : $INTERFACE"
print_none "Tool       : $SCN_TOOL"
print_none "Mode       : $SCN_MODE"
confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full spectrum capture using WSTT"
print_none "Duration   : $SCN_DURATION seconds"
confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

ensure_managed_mode
print_waiting "Running"
simulate_probe_requests

EXIT_CODE=$?
print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0