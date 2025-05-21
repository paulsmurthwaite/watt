# Absolute path to /src/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Common
INTERFACE="wlx00c0cab68175"
ATTACK_DURATION=60

# T007
T007_BSSID="02:00:00:00:00:02"
T007_CHANNEL="6"

# T008
T008_INTERVAL=100  # Beacon send interval in milliseconds
T008_SSID_FILE=t008-ssids.txt

# T009
T009_AUTH_PPS=150  # Packets per second
T009_BSSID="02:00:00:00:00:02"

# T016
T016_PROBE_SSID="WSTTCorpWiFi"
T016_PROBE_BSSID="02:00:00:00:00:04"
T016_PROBE_CHANNEL=6

# T014
T014_TARGET_IP="10.0.0.120"  # Known client IP
T014_INTERFACE="ens33"  # WATT forwarding interface