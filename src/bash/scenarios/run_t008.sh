#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t008.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"

# Prompt user to proceed
user_confirmation() {
    if [[ "$ORCHESTRATION" == "1" ]]; then
        print_info "Orchestration task"
        print_blank
        return 0
    fi
    print_prompt "$1 [y/N]: "
    read -r READY
    [[ "$READY" != "y" && "$READY" != "Y" ]] && return 1
    print_blank
    return 0
}

# Orchestration wait for go
wait_for_go() {
    local GO_FILE="/tmp/watt_go_$1"
    print_info "Waiting for go signal: $GO_FILE"
    while [ ! -f "$GO_FILE" ]; do
        sleep 1
    done
    rm -f "$GO_FILE"
}

# ─── Scenario Introduction ───
print_none "This scenario simulates a Beacon Flood attack.  Fake access points are broadcast at high volume to flood the wireless spectrum with phantom SSIDs."
print_blank

# ─── Access Point Instructions ───
print_section "Scenario Pre-requisites"
print_none "1. No real access point is required"
print_none "2. WSTT full or filtered capture is recommended"
print_none "   to observe fake SSID broadcasts"
print_blank

# ─── Launch Parameters ───
print_section "Scenario Parameters"
print_none "Scenario  : $T008_NAME ($T008_ID)"
print_none "Interface : $INTERFACE"
print_none "Tool      : $T008_TOOL"
print_none "Mode      : $T008_MODE"
print_none "SSID File : $T008_SSID_FILE"
print_none "Interval  : $T008_INTERVAL ms"
print_none "Duration  : $T008_DURATION seconds"
print_blank

# ─── User Confirmation ───
print_prompt "Proceed [y/N]: "
read -r READY
[[ "$READY" != "y" && "$READY" != "Y" ]] && exit 0
print_blank

# ─── WSTT Coordination ───
print_section "WSTT Capture Preparation"
print_action "Launch a full capture using WSTT"
print_none "Ensure monitor mode is enabled and no filters are applied"
print_none "Duration  : $T008_DURATION seconds"
print_blank

# ─── User / Orchestration Sync ───
if [[ "$ORCHESTRATION" == "1" ]]; then
    touch /tmp/watt_ready_capture
    wait_for_go "capture"
else
    user_confirmation "Confirm capturing is active" || exit 0
fi

# ─── Signal Cleanup on Exit ───
cleanup() {
    rm -f /tmp/watt_ready_t008
    rm -f /tmp/watt_ready_capture
}
trap cleanup EXIT

# ─── Attack Execution ───
print_section "Simulation Running"
print_action "Launching simulation"
print_waiting "Running $T008_NAME ($T008_ID)"
touch /tmp/watt_ready_t008  # Ready marker
if [[ "$ORCHESTRATION" == "1" ]]; then
    bash "$SCENARIO_DIR/exec_t008.sh" --wait
else
    bash "$SCENARIO_DIR/exec_t008.sh"
fi
print_success "Simulation complete"
print_blank

# ─── Post-Simulation Instructions ───
print_section "Simulation Complete"
print_action "Run WSTT detection scripts against the saved PCAP file"
print_action "Review the capture in Wireshark (filter: $T008_FILTER_HINT)"

exit 0