# Absolute path to /src/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Alfa AXM Interface
INTERFACE="wlx00c0cab68175"
BSSID="02:00:00:00:00:02"
CHANNEL="6"

# Recommended durations
T007_ATTACK_DURATION=60