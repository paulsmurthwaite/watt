#!/bin/bash

print_section() {
    echo -e "\033[1m[ $1 ]\033[0m"
}

print_info() {
    echo "[*] $1"
}

print_success() {
    echo "[+] $1"
}

print_fail() {
    echo "[x] $1"
}

print_warn() {
    echo "[!] $1"
}

print_action() {
    echo "[>] $1" | fold -s -w 80
}

print_waiting() {
    echo "[~] $1"
}

print_prompt() {
    echo -n "[?] $1"
}

print_none() {
    echo -e "$1"
}

print_wrapped_indent() {
    local label="$1"
    local text="$2"
    local pad="    "
    local full_text="${label}${pad}${text}"
    local wrap_width=80

    # Calculate indentation length (label + 4 spaces)
    local indent_length=$((${#label} + ${#pad}))
    local indent=$(printf "%${indent_length}s")

    echo -e "$full_text" | fold -s -w $wrap_width | sed "2,\$s/^/${indent}/"
}

print_blank() {
    echo ""
}

print_line() {
    echo ""
    echo "─────────────────────────────────────────────────────────────────────────────────────────────"
}