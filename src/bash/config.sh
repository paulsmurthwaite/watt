# Absolute path to /src/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Common
INTERFACE="wlx00c0cab68175"
ATTACK_DURATION=60

# T007
BSSID="02:00:00:00:00:02"
CHANNEL="6"

# T008
T008_INTERVAL=100  # Beacon send interval in milliseconds
T008_SSID_FILE=t008-ssids.txt

# T009
T009_AUTH_PPS=150  # Packets per second
T009_BSSID="02:00:00:00:00:02"