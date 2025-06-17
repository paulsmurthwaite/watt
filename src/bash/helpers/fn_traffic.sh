#!/bin/bash

# ─── Input Argument ───
THREAT_ID="$1"
if [[ -z "$THREAT_ID" ]]; then
    echo "[x] No scenario ID provided. Usage: $0 <TXXX>"
    exit 1
fi

# ─── Paths ───
BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$BASH_DIR/config"
HELPERS_DIR="$BASH_DIR/helpers"
SCENARIO_DIR="$BASH_DIR/scenarios"
SERVICES_DIR="$BASH_DIR/services"
UTILITIES_DIR="$BASH_DIR/utilities"

# ─── Configs ───
CONF_FILE="$CONFIG_DIR/${THREAT_ID,,}.conf"

if [[ ! -f "$CONF_FILE" ]]; then
    print_fail "Configuration file not found: $CONF_FILE"
    exit 1
fi

source "$CONFIG_DIR/global.conf"
source "$CONF_FILE"

# ─── Dependencies  ───
source "$HELPERS_DIR/fn_mode.sh"
source "$HELPERS_DIR/fn_print.sh"
source "$HELPERS_DIR/fn_services.sh"

# ─── Timing ───
START_TIME=$(date +%s)

# ─── Traffic Generation ───
while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if (( ELAPSED >= SCN_DURATION )); then
        break
    fi

    # ─── HTTP Requests ───
    print_blank
    print_action "Generating HTTP GET requests to Captive Portal"
    print_info "GET /"
    curl -s -o /dev/null -w "Status: %{http_code}\n" "http://$SCN_GATEWAY"
    curl -s "http://$SCN_GATEWAY" | head -n 5

    print_info "GET /index.html"
    curl -s -o /dev/null -w "Status: %{http_code}\n" "http://$SCN_GATEWAY/index.html"
    curl -s "http://$SCN_GATEWAY/index.html" | head -n 5

    # ─── DNS Queries ───
    print_blank
    print_action "Simulating DNS queries to local resolver"
    for domain in wstt.test watt.test wapt.test; do
        print_info "Resolving: $domain"
        dig +short @"$SCN_GATEWAY" "$domain"
    done

    print_info "Resolving: captive.portal"
    nslookup captive.portal "$SCN_GATEWAY"

    # ─── Simulated Credential Submission ───
    print_action "Submitting fake credentials to HTTP login page"
    curl -s -o /dev/null -w "POST /submit → HTTP %{http_code}\n" \
        -X POST -d "username=admin&password=admin" "http://$SCN_GATEWAY/submit"

    # ─── ICMP Ping ───
    print_blank
    print_action "Sending ICMP ping to AP gateway"
    ping -c 3 "$SCN_GATEWAY" | grep -E 'bytes from|packets transmitted'

    # ─── NTP Request ───
    print_blank
    print_action "Sending NTP request to local NTP server"
    ntpdate -u "$SCN_GATEWAY" | grep -E 'adjust time server|no server suitable'

    print_blank
    sleep "$SCN_INTERVAL"
    clear
done

exit 0