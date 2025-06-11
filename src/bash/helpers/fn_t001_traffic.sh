#!/bin/bash

# ─── Simulated Unencrypted Traffic Generator for T001 ───
# This script is executed by exec_t001.sh on WATT

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t001.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"

# ─── Timing ───
START_TIME=$(date +%s)

# ─── Traffic Generation ───
while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if (( ELAPSED >= T001_DURATION )); then
        break
    fi

    # ─── HTTP Requests ───
    print_blank
    print_action "Generating HTTP GET requests to Captive Portal"
    print_info "GET /"
    curl -s -o /dev/null -w "Status: %{http_code}\n" http://10.0.0.1
    curl -s http://10.0.0.1 | head -n 5

    print_info "GET /index.html"
    curl -s -o /dev/null -w "Status: %{http_code}\n" http://10.0.0.1/index.html
    curl -s http://10.0.0.1/index.html | head -n 5

    # ─── DNS Queries ───
    print_blank
    print_action "Simulating DNS queries to local resolver"
    for domain in wstt.test watt.test wapt.test; do
        print_info "Resolving: $domain"
        dig +short @$T001_GATEWAY "$domain"
    done

    print_info "Resolving: captive.portal"
    nslookup captive.portal "$T001_GATEWAY"

    # ─── Simulated Credential Submission ───
    print_action "Submitting fake credentials to HTTP login page"
    curl -s -o /dev/null -w "POST /submit → HTTP %{http_code}\n" \
        -X POST -d "username=admin&password=admin" http://10.0.0.1/submit

    # ─── ICMP Ping ───
    print_blank
    print_action "Sending ICMP ping to AP gateway"
    ping -c 3 10.0.0.1 | grep -E 'bytes from|packets transmitted'

    # ─── NTP Request ───
    print_blank
    print_action "Sending NTP request to local NTP server"
    ntpdate -u 10.0.0.1 | grep -E 'adjust time server|no server suitable'

    print_blank
    sleep "$T001_INTERVAL"
done

exit 0