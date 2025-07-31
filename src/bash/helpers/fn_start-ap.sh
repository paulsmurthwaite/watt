#!/bin/bash

# ─── Input Argument ───
SCENARIO_ID="$1"
if [[ -z "$SCENARIO_ID" ]]; then
    echo "[x] No scenario ID provided. Usage: $0 <TXXX>"
    exit 1
fi

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SCENARIO_DIR="$BASH_DIR/scenarios"
SERVICES_DIR="$BASH_DIR/services"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
CONF_FILE="$CONFIG_DIR/${SCENARIO_ID,,}.conf"
AP_FILE="$CONFIG_DIR/ap_${SCENARIO_ID,,}.cfg"

if [[ ! -f "$CONF_FILE" || ! -f "$AP_FILE" ]]; then
    echo "[x] Missing config: $CONF_FILE or $AP_FILE"
    exit 1
fi

source "$CONFIG_DIR/global.conf"
source "$CONF_FILE"
source "$AP_FILE"

# ─── Dependencies  ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_services.sh"

# ─── Export for envsubst and BSSID support ───
export INTERFACE SSID CHANNEL HIDDEN WPA_MODE PASSPHRASE BSSID BEACON_INT COUNTRY_CODE

# ─── Start AP ───
print_info "Launching Access Point"

# ─── Generate hostapd.conf ───
GENERATED_CONF=$(cat "$CONFIG_DIR/hostapd.conf.template")

# Conditionally remove optional parameters if they are not set
if [[ -z "$WPA_MODE" ]]; then
    print_action "WPA mode not set, removing WPA parameters from config."
    GENERATED_CONF=$(echo "$GENERATED_CONF" | grep -v -e '^wpa=' -e '^wpa_passphrase=' -e '^wpa_key_mgmt=' -e '^rsn_pairwise=' -e '^wpa_pairwise=')
fi

if [[ -z "$BEACON_INT" ]]; then
    GENERATED_CONF=$(echo "$GENERATED_CONF" | grep -v '^beacon_int=')
fi

if [[ -z "$COUNTRY_CODE" ]]; then
    GENERATED_CONF=$(echo "$GENERATED_CONF" | grep -v '^country_code=')
fi

# Perform substitution on the cleaned-up template
echo "$GENERATED_CONF" | envsubst > /tmp/hostapd.conf

# ─── NetworkManager ───
sudo systemctl stop NetworkManager

# ─── Interface ───
print_waiting "Configuring interface $INTERFACE"

bash "$SERVICES_DIR/set-interface-down.sh"
print_action "Spoofing interface MAC to match BSSID: $SCN_BSSID"
sudo ip link set "$INTERFACE" address "$SCN_BSSID"

sudo ip addr add "${SCN_GATEWAY}/24" dev "$INTERFACE"
bash "$SERVICES_DIR/set-interface-up.sh"

print_success "Interface $INTERFACE configured"

# ─── IP forwarding ───
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

# ─── hostapd ───
sudo hostapd /tmp/hostapd.conf -B
if ! pgrep hostapd > /dev/null; then
    print_fail "hostapd failed to start"
    exit 1
fi

# ─── AP status flag ───
echo "$SCN_SSID|$(date +%s)|nat" > /tmp/ap_active

# ─── NAT ───
print_action "Starting NAT: Client Internet access ENABLED"
sudo iptables -t nat -A POSTROUTING -s "$SCN_NETWORK" -o "$SCN_FWD_INTERFACE" -j MASQUERADE
sudo iptables -A FORWARD -i "$INTERFACE" -o "$SCN_FWD_INTERFACE" -j ACCEPT
sudo iptables -A FORWARD -i "$SCN_FWD_INTERFACE" -o "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT

# ─── Services ───
start_dns_service
start_ntp_service
start_http_server

exit 0