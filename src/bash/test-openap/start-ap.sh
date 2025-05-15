#!/bin/bash
# Usage:
# ./start-ap.sh nat (Internet enabled)
# ./start-ap (Internet disabled)

set -e

IFACE="wlx00c0cab4b58c"
GATEWAY="10.0.0.1"
CONF_DIR="$(dirname "$0")"

# Stop NetworkManager
echo "{+] Stopping NetworkManager ... "
sudo systemctl stop NetworkManager

# Configure Interface
echo "{+] Configuring Interface $IFACE ... "
sudo ip link set $IFACE down
sudo ip addr flush dev $IFACE
sudo ip addr add ${GATEWAY}/24 dev $IFACE
sudo ip link set $IFACE up

# Enable IP Forwarding
echo "{+] Enabling IP Forwarding ... "
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

# Start hostapd
echo "{+] Starting hostapd ... "
sudo hostapd "$CONF_DIR/hostapd.conf" -B

# Stop systemd-resolved
echo "{+] Stopping systemd-resolved ... "
sudo systemctl stop systemd-resolved

# Unlink resolv.conf
echo "{+] Unlinking /etc/resolv.conf ... "
sudo rm -f /etc/resolv.conf
echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf > /dev/null

# Start dnsmasq
echo "{+] Starting dnsmasq ... "
sudo dnsmasq -C "$CONF_DIR/dnsmasq.conf"

# NAT configuration
if [[ "$1" == "nat" ]]; then
  echo "{+] Applying NAT and forwarding rules ... " 
  sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ens33 -j MASQUERADE
  sudo iptables -A FORWARD -i $IFACE -o ens33 -j ACCEPT
  sudo iptables -A FORWARD -i ens33 -o $IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
else
  echo "{+] Skipping NAT setup (internet blocked for clients) ... "
fi

echo "{+] WSTT-OpenAP ENABLED ... "