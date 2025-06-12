#!/bin/bash

# ─── Simulated Unencrypted Traffic Generator for T005 ───
# This script is executed by exec_t005.sh on WATT

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"

# ─── Configs ───
source "$CONFIG_DIR/global.conf"
source "$CONFIG_DIR/t005.conf"

# ─── Helpers ───
source "$HELPERS_DIR/fn_print.sh"

# ─── Timing ───
START_TIME=$(date +%s)

# ─── Traffic Generation ───
while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if (( ELAPSED >= T005_DURATION )); then
        break
    fi

    # ─── HTTP Requests ───
    print_blank
    print_action "Generating HTTP GET requests to Captive Portal"
    print_info "GET /"
    curl -s -o /dev/null -w "Status: %{http_code}\n" http://$GATEWAY
    curl -s http://$GATEWAY | head -n 5

    print_info "GET /index.html"
    curl -s -o /dev/null -w "Status: %{http_code}\n" http://$GATEWAY/index.html
    curl -s http://$GATEWAY/index.html | head -n 5

    # ─── DNS Queries ───
    print_blank
    print_action "Simulating DNS queries to local resolver"
    for domain in wstt.test watt.test wapt.test; do
        print_info "Resolving: $domain"
        dig +short @$GATEWAY "$domain"
    done

    print_info "Resolving: captive.portal"
    nslookup captive.portal "$GATEWAY"

    # ─── Simulated Credential Submission ───
    print_action "Submitting fake credentials to HTTP login page"
    curl -s -o /dev/null -w "POST /submit → HTTP %{http_code}\n" \
        -X POST -d "username=admin&password=admin" http://$GATEWAY/submit

    # ─── ICMP Ping ───
    print_blank
    print_action "Sending ICMP ping to AP gateway"
    ping -c 3 $GATEWAY | grep -E 'bytes from|packets transmitted'

    # ─── NTP Request ───
    print_blank
    print_action "Sending NTP request to local NTP server"
    ntpdate -u $GATEWAY | grep -E 'adjust time server|no server suitable'

    print_blank
    sleep "$T005_INTERVAL"
done

exit 0