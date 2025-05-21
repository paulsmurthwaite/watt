# Absolute path to /src/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Alfa AXM Interface
INTERFACE="wlx00c0cab68175"
BSSID="02:00:00:00:00:02"
CHANNEL="6"

# Common
ATTACK_DURATION=60

# T008
T008_INTERVAL=100  # Beacon send interval in milliseconds
T008_SSID_FILE=t008-ssids.txt