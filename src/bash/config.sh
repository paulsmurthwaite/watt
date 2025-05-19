# Absolute path to /src/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Interface Configuration
INTERFACE="wlx00c0cab4b58c"
CHANNELS_24GHZ_UK="1,2,3,4,5,6,7,8,9,10,11,12,13"
CHANNELS_5GHZ_UK="36,40,44,48"
