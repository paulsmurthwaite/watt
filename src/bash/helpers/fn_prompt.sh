#!/bin/bash
# ─── Prompt user to proceed ───

confirmation() {
    print_blank
    print_prompt "Proceed [y/N]: "
    read -r READY
    [[ "$READY" != "y" && "$READY" != "Y" ]] && exit 0
    print_blank
}