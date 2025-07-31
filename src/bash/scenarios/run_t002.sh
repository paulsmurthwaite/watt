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

# --- Cleanup ---
cleanup() {
    print_info "Cleaning up..."
    if [[ -n "$SSID_LIST_FILE" && -f "$SSID_LIST_FILE" ]]; then
        rm "$SSID_LIST_FILE"
        print_success "Removed temporary SSID file."
    fi
    ensure_managed_mode
    print_success "Interface restored to managed mode."
}

# --- Check mdk4 ---
if ! command -v mdk4 &> /dev/null; then
    print_fail "mdk4 is not installed. This script requires mdk4 for direct probe request injection."
    exit 1
fi

# --- Trap for cleanup on exit ---
trap cleanup EXIT SIGINT

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This scenario demonstrates the ability of a passive attacker to capture wireless probe request frames transmitted by client devices.  These frames are sent when clients actively search for known Wi-Fi networks (SSIDs), often revealing previous connection history and preferred network names.

The attacker listens silently on the wireless channel to capture these requests.  This can be used to:

1. Profile a user's historical locations or home/office networks
2. Identify targets for directed attacks (e.g. Evil Twin or Directed Probe Response)
3. Correlate device behaviour with unique identifiers (e.g. MAC addresses)"
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. AP Profile: $SCN_PROFILE"
print_blank

# ─── Show Capture Config ───
print_section "Capture Preparation"
print_none "Type:          $SCN_CAPTURE"
print_none "BSSID:         $SCN_BSSID"
print_none "Channel:       $SCN_CHANNEL"
print_none "Duration:      $SCN_DURATION seconds"
print_blank
print_action "Launch Capture"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

print_action "Preparing for probe injection..."

# Create a temporary file with the list of SSIDs
SSID_LIST_FILE=$(mktemp)
for SSID in "${SCN_SSIDS[@]}"; do
    echo "$SSID" >> "$SSID_LIST_FILE"
done
print_success "Created temporary SSID list."

print_action "Switching interface to monitor mode for injection..."
ensure_monitor_mode
print_success "Interface is in monitor mode."
print_blank

print_info "Running T002 - Probe Request injection for $SCN_DURATION seconds..."
print_waiting "Injecting directed probe requests for SSIDs in t002.conf"

# Use mdk4's probe request mode 'p' with the SSID file
# mdk4 exits after one pass of the SSID file. To ensure the attack runs for
# the full duration, we wrap the mdk4 call in a loop that is then managed
# by the timeout command. We also redirect the loop's output to /dev/null
# to keep the screen clean. The `timeout` command can be unreliable with
# process groups, so we will manage the process lifetime manually.

# Start the injection loop in the background and get its PID
bash -c "while true; do mdk4 '$INTERFACE' p -f '$SSID_LIST_FILE' -s 100 &>/dev/null; sleep 1; done" &
INJECTION_PID=$!

# Allow the main script to wait for the specified duration
sleep "$SCN_DURATION"

# Terminate the background injection loop and wait for it to exit cleanly
kill "$INJECTION_PID"
wait "$INJECTION_PID" 2>/dev/null

print_blank

exit 0