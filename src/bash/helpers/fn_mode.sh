#!/bin/bash

# ─── Monitor ───
ensure_monitor_mode() {
MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
if [[ "$MODE" != "monitor" ]]; then
    print_action "Enabling Monitor mode"
    bash "$SERVICES_DIR/set-mode-monitor.sh"
    print_success "Interface set to Monitor mode"
fi
}

# ─── Managed ───
ensure_managed_mode() {
MODE=$(iw dev "$INTERFACE" info | awk '/type/ {print $2}')
if [[ "$MODE" != "managed" ]]; then
    print_action "Reverting to Managed mode"
    bash "$SERVICES_DIR/set-mode-managed.sh"
    print_success "Interface set to Managed mode"
fi
}