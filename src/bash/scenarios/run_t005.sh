#!/bin/bash

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SERVICES_DIR="$BASH_DIR/services"
SCENARIO_DIR="$BASH_DIR/scenarios"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t005.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"

# ─── Initial Proceed? ───
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

# ─── Orchestration: Wait for Go ───
wait_for_go() {
    local GO_FILE="/tmp/watt_go_$1"
    print_info "Waiting for go signal: $GO_FILE"
    while [ ! -f "$GO_FILE" ]; do
        sleep 1
    done
    rm -f "$GO_FILE"
}

# ─── Show Intro ───
print_none "This scenario simulates an attacker deploying an unauthorised, open Wi-Fi"
print_none "access point in a trusted network environment.  The goal is to lure unsuspecting"
print_none "users to connect, thereby enabling passive traffic observation or active"
print_none "manipulation (e.g. DNS spoofing, phishing pages, or data capture)."
print_blank
print_none "Unlike Evil Twin attacks, this rogue AP does not impersonate a known SSID - "
print_none "it presents a new, legitimate-looking network name (e.g. 'Guest_Wifi' or)"
print_none "'FreePublicWiFi' designed to attract users."
print_blank

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. Legitimate secure access point (e.g. WSTT-CorpAP) must be active"
print_none "2. Rogue access point (WSTT-CorpAP-Guest) will be launched on WATT"
print_none "3. WSTT full/filtered capture must be started before simulation begins"
print_blank

# ─── Show simulation params ───
print_section "Scenario Parameters"
print_none "Scenario  : $T005_NAME ($T005_ID)"
print_none "Interface : $INTERFACE"
print_none "Tool      : $T005_TOOL"
print_none "Mode      : $T005_MODE"
print_blank

# ─── Proceed? ───
print_prompt "Proceed [y/N]: "
read -r READY
[[ "$READY" != "y" && "$READY" != "Y" ]] && exit 0
print_blank

# ─── Show AP/Client params ───
print_section "Access Point & Client Preparation"
print_none "1. Ensure [PROFILEXXX] is active on WAPT"
print_none "2. Prepare a client device to join the rogue AP SSID: $T005_ROGUE_SSID"
print_blank

# ─── Proceed? ───
if [[ "$ORCHESTRATION" == "1" ]]; then
    touch /tmp/watt_ready_ap
    wait_for_go "ap"
else
    user_confirmation "Proceed [y/N]: " || exit 0
fi

# ─── Show Capture params ───
print_section "WSTT Capture Preparation"
print_none "1. Launch a WSTT Full or Filtered (Channel) capture on channel: $T005_CHANNEL for $T005_DURATION seconds"
print_blank

# ─── Proceed? ───
if [[ "$ORCHESTRATION" == "1" ]]; then
    touch /tmp/watt_ready_capture
    wait_for_go "capture"
else
    user_confirmation "Proceed [y/N]: " || exit 0
fi

# ─── Exit Cleanup ───
cleanup() {
    rm -f /tmp/watt_ready_t005
    rm -f /tmp/watt_ready_capture
}
trap cleanup EXIT

# ─── Execution ───
touch /tmp/watt_ready_t005  # Ready marker
if [[ "$ORCHESTRATION" == "1" ]]; then
    bash "$SCENARIO_DIR/exec_t005.sh" --wait
else
    bash "$SCENARIO_DIR/exec_t005.sh"
fi

# ─── Post-Simulation ───
print_blank
print_section "Simulation Complete"
print_none "1. Run WSTT detection scripts against the saved PCAP file"
print_none "2. Review the capture in Wireshark (filter: $T005_FILTER_HINT)"

exit 0