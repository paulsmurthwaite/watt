#!/bin/bash
set -e

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
source "$CONFIG_DIR/ap_t004.cfg"

# ─── Helpers ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_services.sh"

# ─── Export for envsubst and BSSID support ───
export INTERFACE SSID CHANNEL HIDDEN WPA_MODE PASSPHRASE WPA3 BSSID

# ─── Generate hostapd.conf ───
if [[ -z "$WPA_MODE" ]]; then
    grep -v '^wpa=' "$CONFIG_DIR/hostapd.conf.template" \
    | grep -v '^wpa_passphrase=' \
    | grep -v '^wpa_key_mgmt=' \
    | grep -v '^rsn_pairwise=' \
    | grep -v '^wpa_pairwise=' \
    | envsubst > /tmp/hostapd.conf
else
    envsubst < "$CONFIG_DIR/hostapd.conf.template" > /tmp/hostapd.conf
fi

# ─── WPA3 ───
if [[ "$WPA3" == "1" ]]; then
    {
        echo "ieee80211w=2"
        echo "sae_require_mfp=1"
        echo "wpa_key_mgmt=SAE WPA-PSK"
    } >> /tmp/hostapd.conf
fi

ensure_managed_mode

# ─── NetworkManager ───
sudo systemctl stop NetworkManager

# ─── Interface ───
print_waiting "Configuring interface $INTERFACE"

bash "$SERVICES_DIR/set-interface-down.sh"  # IF Down
print_action "Spoofing interface MAC to match BSSID: $T004_BSSID"
sudo ip link set "$INTERFACE" address "$T004_BSSID"

sudo ip addr add "${GATEWAY}/24" dev "$INTERFACE"
bash "$SERVICES_DIR/set-interface-up.sh"  # IF Up

print_success "Interface $INTERFACE configured"

# ─── IP forwarding ───
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

# ─── hostapd ───
sudo hostapd /tmp/hostapd.conf -B

# ─── NAT ───
print_action "Starting NAT: Client Internet access ENABLED"
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o "$FWD_INTERFACE" -j MASQUERADE
sudo iptables -A FORWARD -i "$INTERFACE" -o "$FWD_INTERFACE" -j ACCEPT
sudo iptables -A FORWARD -i "$FWD_INTERFACE" -o "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT

# ─── Services ───
start_dns_service
start_ntp_service
start_http_server

# ─── AP status flag ───
echo "$SSID|$(date +%s)|nat" > /tmp/wapt_ap_active