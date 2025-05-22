#!/bin/bash

cleanup() {
    print_blank
    print_info "Starting cleanup"
    rm -f /tmp/watt_attack_active

    # Revert mode
    ensure_managed_mode

    exit 0   
}