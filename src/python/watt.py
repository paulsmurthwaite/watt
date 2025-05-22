#!/usr/bin/env python3
"""watt.py

Main entry point for the Wireless Attack Test Toolkit (WATT) menu interface.

This script provides a simple, operator-friendly CLI for launching predefined
wireless attack scenarios against test environments. Each scenario maps to a
specific threat profile and is executed using underlying Bash-based tooling.

WATT is intended for use in isolated lab environments only. It does not capture
or analyse traffic. Detection and analysis should be performed separately using WSTT.

The menu system acts as the central launcher for attack scripts, using screen
clearing and section redrawing to support usability without introducing graphical complexity.

Author:      Paul Smurthwaite
Date:        2025-05-19
Module:      TM470-25B
"""

import os
import pyfiglet
import subprocess

# ─── UI Helpers ───
# UI Colour Dictionary
COLOURS = {
    "reset":  "\033[0m",
    "bold":   "\033[1m",
    "grey":   "\033[90m",
    "red":    "\033[91m",
    "green":  "\033[92m",
    "yellow": "\033[93m",
    "magenta": "\033[95m",
    "warn":   "\033[38;5;226m",  # amber
}

# UI Colour
def colour(text, style):
    """
    Apply ANSI colour styling to text.
    """
    return f"{COLOURS.get(style, '')}{text}{COLOURS['reset']}"

# UI Banner
def ui_banner():
    """
    Display ASCII banner.
    """
    ascii_banner = pyfiglet.figlet_format("WATT", font="ansi_shadow")
    print(colour(ascii_banner, "red"))

# UI Header
def ui_header(title="Wireless Attack Testing Toolkit"):
    """
    Display section header.
    """
    styled = f"{COLOURS['bold']}{COLOURS['red']}[ {title} ]{COLOURS['reset']}"
    print(styled)

# UI Divider
def ui_divider():
    """
    Display divider.
    """
    print(colour("-----------------------------------", "grey"))
    print()

# UI Subtitle
def ui_subtitle():
    """
    Display combined subtitle.
    """
    ui_divider()
    print_interface_status()
    print_service_status()
    ui_divider()

# UI Standard Header
def ui_standard_header(menu_title=None):
    """
    Render standard UI header block: banner, main title, subtitle.
    Optionally takes a menu title to display immediately after.
    """
    ui_banner()       # ASCII banner
    ui_header()       # Toolkit title
    print()
    ui_subtitle()     # Divider + interface + service info

    if menu_title:
        ui_header(menu_title)  # Current menu title
        print()

# UI Clear Screen
def ui_clear_screen():
    """
    Clear terminal screen.
    """
    os.system("cls" if os.name == "nt" else "clear")

# UI Invalid Option
def ui_pause_on_invalid():
    """
    Display invalid input message and pause.
    """
    print(colour("\n[!] Invalid option. Please try again.", "red"))
    input("[Press Enter to continue]")

# ─── Display Interface ───
# 
def print_interface_status():
    """
    Print the current interface, state, and mode.
    """
    interface, state_raw, mode_raw = get_interface_details()

    state = state_raw.title()
    mode = "AP" if mode_raw.lower() == "ap" else mode_raw.title()

    # Determine colours
    interface_display = colour(interface, "warn")
    state_display = colour(state, "green" if state.lower() == "up" else "red")

    if mode_raw.lower() == "managed":
        mode_display = colour(mode, "green")
    elif mode_raw.lower() == "monitor":
        mode_display = colour(mode, "red")
    elif mode_raw.lower() == "ap":
        mode_display = colour(mode, "yellow")
    else:
        mode_display = colour(mode, "reset")

    # Output
    print(f"[ Interface       ] {interface_display}")
    print(f"[ Interface State ] {state_display}")
    print(f"[ Interface Mode  ] {mode_display}")
    print()

# ─── Display Service ───
# 
def print_service_status():
    """
    Display Attack Tool status with colour formatting.
    """
    atk_file = "/tmp/watt_attack_active"
    atk_raw = "Stopped"

    if os.path.exists(atk_file):
        with open(atk_file, "r") as f:
            atk_raw = f"Running ({f.read().strip()})"

    atk_colour = "\033[92m" if atk_raw.startswith("Stopped") else "\033[91m"
    style = "green" if atk_raw.startswith("Stopped") else "yellow"

    print(f"[ Attack Status ] {colour(atk_raw, style)}")
    print()

# ─── Interface Helpers ───
#
def get_interface_details():
    """
    Returns (interface, state, mode) from get-current-interface.sh.
    """
    script_path = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "bash", "services", "get-current-interface.sh")
    )

    if not os.path.exists(script_path):
        return ("[!] Not found", "[!] Not found", "[!] Not found")

    try:
        result = subprocess.run(["bash", script_path], capture_output=True, text=True, check=True)
        lines = result.stdout.strip().splitlines()
        interface = lines[0].split(":")[1].strip().upper() if len(lines) > 0 else "?"
        state     = lines[1].split(":")[1].strip().upper() if len(lines) > 1 else "?"
        mode      = lines[2].split(":")[1].strip().upper() if len(lines) > 2 else "?"
        return (interface, state, mode)
    except subprocess.CalledProcessError:
        return ("[!] Script error", "[!] Script error", "[!] Script error")

def get_current_interface():
    """
    Returns interface, state, mode.
    """
    return get_interface_details()[0]

def get_interface_state():
    """
    Returns state from get_interface_details.
    """
    return f"State:     {get_interface_details()[1]}"

def get_interface_mode():
    """
    Returns mode from get_interface_details.
    """
    return f"Mode:      {get_interface_details()[2]}"

# ─── Display Main Menu ───
# 
def show_menu():
    """
    Display main menu.
    """
    ui_clear_screen()
    
    # Header block
    ui_standard_header("Main Menu")

    # Menu block
    ui_header("Automated/Guided Playbooks")
    print("[1] Threat Scenarios")
    print()
    ui_header("Developer Tools")
    print("[2] Attack Tools")
    print()
    ui_header("Utilities")
    print("[3] Service Control")
    print("[4] Help | About")

    # Exit option
    print("\n[0] Exit")

# ─── Bash Script Handler ───
#
def run_bash_script(script_name, pause=True, capture=True, clear=True, title=None):
    """
    Executes a Bash script located under /src/bash.
    
    Args:
        script_name (str): Script name without extension.
        title (str): Optional header to display before execution
        pause (bool): Whether to wait for user input after execution.
    """
    if clear:
        ui_clear_screen()

    if title:
        ui_header(title)
        print()

    # Bash script path
    script_path = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "bash", f"{script_name}.sh")
    )

    if not os.path.exists(script_path):
        print(f"[x] Script not found: {script_name}.sh")
        return
    
    try:
        if capture:
            result = subprocess.run(
                ["bash", script_path],
                check=True,
                capture_output=True,
                text=True
            )
        else:
            subprocess.run(["bash", script_path], check=True)
    
    except subprocess.CalledProcessError as e:
        if e.returncode == 124:
            print(f"[x] Script timed out after specified duration.")
        else:
            print(f"[x] Script failed: {script_name}.sh")
            if e.stderr:
                print(e.stderr.strip())

    if pause:
        input("\n[Press Enter to return to menu]")

def threat_scenario():
    """
    Launch Threat Scenario submenu.
    """
    def threat_t001():
        run_bash_script("scenarios/run_t001", pause=True, capture=False, clear=False, title="Threat Scenario: Unencrypted Traffic Capture (T001)")

    def threat_t002():
        run_bash_script("scenarios/run_t002", pause=True, capture=False, clear=False, title="Threat Scenario: Probe Request Snooping (T002)")

    def threat_t004():
        run_bash_script("scenarios/run_t004", pause=True, capture=False, clear=False, title="Threat Scenario: Evil Twin Attack (T004)")

    def threat_t005():
        run_bash_script("scenarios/run_t005", pause=True, capture=False, clear=False, title="Threat Scenario: Open Rogue AP (T005)")

    def threat_t006():
        run_bash_script("scenarios/run_t006", pause=True, capture=False, clear=False, title="Threat Scenario: Misconfigured Access Point (T006)")

    def threat_t007():
        run_bash_script("scenarios/run_t007", pause=True, capture=False, clear=True, title="Threat Scenario: Deauthentication Flood (T007)")

    def threat_t009():
        run_bash_script("scenarios/run_t009", pause=True, capture=False, clear=False, title="Threat Scenario: Authentication Flood (T009)")

    def threat_t014():
        run_bash_script("scenarios/run_t014", pause=True, capture=False, clear=False, title="Threat Scenario: ARP Spoofing from Wireless Entry Point (T014)")

    def threat_t015():
        run_bash_script("scenarios/run_t015", pause=True, capture=False, clear=False, title="Threat Scenario: Malicious Hotspot Auto-Connect (T015)")

    def threat_t016():
        run_bash_script("scenarios/run_t016", pause=True, capture=False, clear=False, title="Threat Scenario: Directed Probe Response (T016)")

    actions = {
        "1":  threat_t001,
        "2":  threat_t002,
        "3":  threat_t004,
        "4":  threat_t005,
        "5":  threat_t006,
        "6":  threat_t007,
        "7":  threat_t009,
        "8":  threat_t014,
        "9":  threat_t015,
        "10": threat_t016
    }

    while True:
        ui_clear_screen()

        # Header block
        ui_standard_header("Threat Scenarios")

        # Menu block
        ui_header("Access Point Threats")
        print("[1]   Run Unencrypted Traffic Capture scenario (T001)")
        print("[2]   Run Probe Request Snooping scenario (T002)")
        print("[3]   Run Evil Twin Attack scenario (T004)")
        print("[4]   Run Open Rogue AP scenario (T005)")
        print("[5]   Run Misconfigured Access Point scenario (T006)")
        print()
        ui_header("Client Exploits")
        print("[6]   Run Deauthentication Flood scenario (T007)")
        print("[7]   Run Authentication Flood scenario (T009)")
        print("[8]   Run ARP Spoofing from Wireless Entry Point scenario (T014)")
        print("[9]   Run Malicious Hotspot Auto-Connect scenario (T015)")
        print("[10]  Run Directed Probe Response scenario (T016)")
        print("\n[0] Return to Main Menu")

        # Input
        choice = input("\n[?] Select an option: ")

        if choice == "0":
            break

        action = actions.get(choice)
        if action:
            print()
            action()
        else:
            ui_pause_on_invalid()

def dev_tools():
    """
    Developer Tools submenu.
    """

    def run_deauth():
        run_bash_script("utilities/run_mdk4_deauth", pause=True, capture=False, clear=False, title="T007 - Deauthentication Flood")

    def run_beacon():
        run_bash_script("utilities/run_mdk4_beacon", pause=True, capture=False, clear=False, title="T008 - Beacon Flood")

    def run_auth():
        run_bash_script("utilities/run_mdk4_auth", pause=True, capture=False, clear=False, title="T009 - Authentication Flood")

    def run_arp_spoof():
        run_bash_script("utilities/run_bettercap_arp", pause=True, capture=False, clear=False, title="T014 - ARP Spoofing")

    def run_probe():
        run_bash_script("utilities/run_airbase_probe", pause=True, capture=False, clear=False, title="T016 - Directed Probe Response")

    def stop_attack():
        run_bash_script("utilities/stop-attack", pause=True, capture=False, clear=False, title="Stop Attack")

    actions = {
        "1": run_deauth,
        "2": run_beacon,
        "3": run_auth,
        "4": run_arp_spoof,
        "5": run_probe,
        "S": stop_attack
    }

    while True:
        ui_clear_screen()

        # Header block
        ui_standard_header("Attack Tools")

        print("[1] Launch Deauthentication Flood Attack (T007)")
        print("[2] Launch Beacon Flood Attack (T008)")
        print("[3] Launch Authentication Flood Attack (T009)")
        print("[4] Launch ARP Spoofing Attack (T014)")
        print("[5] Launch Directed Probe Response Attack (T016)")
        print("\n[S] Stop Attack")
        print("\n[0] Return to Main Menu")

        # Input
        choice = input("\n[?] Select an option: ").strip().upper()

        if choice == "0":
            break

        action = actions.get(choice)
        if action:
            print()
            action()
        else:
            ui_pause_on_invalid()

def service_control():
    """
    Service Control submenu.
    """

    def interface_state():
        """
        Interface State submenu.
        """

        def set_interface_down():
            run_bash_script("services/set-interface-down", pause=False, capture=False, clear=False, title="Change Interface State")

        def set_interface_up():
            run_bash_script("services/set-interface-up", pause=False, capture=False, clear=False, title="Change Interface State")

        actions = {
            "1": set_interface_down,
            "2": set_interface_up
        }

        while True:
            ui_clear_screen()
            
            # Header block
            ui_standard_header("Set Interface State")
                    
            # Menu block                    
            print("[1] Set interface state DOWN")
            print("[2] Set interface state UP")
            print("\n[0] Return to Service Control Menu")

            # Input
            choice = input("\n[?] Select an option: ")

            if choice == "0":
                break

            action = actions.get(choice)
            if action:
                print()
                action()
            else:
                ui_pause_on_invalid()

    def interface_mode():
        """
        Interface mode submenu.
        """

        def switch_to_managed():
            run_bash_script("services/set-mode-managed", pause=False, capture=False, clear=False, title="Change Interface Mode")

        def switch_to_monitor():
            run_bash_script("services/set-mode-monitor", pause=False, capture=False, clear=False, title="Change Interface Mode")

        actions = {
            "1": switch_to_managed,
            "2": switch_to_monitor
        }

        while True:
            ui_clear_screen()

            # Header block
            ui_standard_header("Set Interface Mode")

            # Menu block
            print("[1] Set interface mode MANAGED")
            print("[2] Set interface mode MONITOR")
            print("\n[0] Return to Service Control Menu")

            # Input
            choice = input("\n[?] Select an option: ")

            if choice == "0":
                break

            action = actions.get(choice)
            if action:
                print()
                action()
            else:
                ui_pause_on_invalid()

    def interface_reset():
        """
        Reset interface submenu.
        """

        def perform_soft_reset():
            run_bash_script("services/reset-interface-soft", pause=False, capture=False, clear=False, title="Reset Interface (Soft)")

        def perform_hard_reset():
            run_bash_script("services/reset-interface-hard", pause=False, capture=False, clear=False, title="Reset Interface (Hard)")

        actions = {
            "1": perform_soft_reset,
            "2": perform_hard_reset
        }

        while True:
            ui_clear_screen()

            # Header block
            ui_standard_header("Reset Interface")

            print("[1] Perform Soft Reset (Interface Down/Up)")
            print("[2] Perform Hard Reset (Interface Unload/Reload)")
            print("\n[0] Return to Service Control Menu")

            # Input
            choice = input("\n[?] Select an option: ")

            if choice == "0":
                break

            action = actions.get(choice)
            if action:
                print()
                action()
            else:
                ui_pause_on_invalid()

    actions = {
        "1": interface_state,
        "2": interface_mode,
        "3": interface_reset
    }

    while True:
        ui_clear_screen()

        # Header block
        ui_standard_header("Service Control")

        print("[1] Change Interface State")
        print("[2] Change Interface Mode")
        print("[3] Reset Interface")
        print("\n[0] Return to Main Menu")

        # Input
        choice = input("\n[?] Select an option: ")

        if choice == "0":
            break

        action = actions.get(choice)
        if action:
            ui_clear_screen()
            action()
        else:
            ui_pause_on_invalid()

def help_about():
    """
    Help | About submenu.
    """
    ui_clear_screen()

    # Header block
    ui_standard_header("Help | About")

    print("WATT (Wireless Attack Testing Toolkit) provides a menu-driven interface")
    print("to launch predefined wireless attack scenarios in a controlled")
    print("testing environment.  Each attack corresponds to a specific threat")
    print("profile and is executed using underlying Bash-based tools.")
    print()
    print("This toolkit is intended for use in isolated lab environments only.")
    print("All testing must be performed on equipment and networks you own")
    print("or have explicit permission to test.")
    print()
    print("Captured traffic and detections should be handled separately using WSTT.")
    print()
    print("Author : Paul Smurthwaite")
    print("Module : TM470-25B")
    print("Date   : May 2025")

    # Input
    input("\n[Press Enter to return to menu]")

def main():
    """
    User input handler.
    """
    while True:
        show_menu()
        choice = input("\n[?] Select an option: ")
        
        if choice == "1":
            threat_scenario()
        elif choice == "2":
            dev_tools()
        elif choice == "3":
            service_control()
        elif choice == "4":
            help_about()
        elif choice == "0":
            print(colour("\n[+] Exiting to shell.", "green"))
            break
        
        else:
            ui_pause_on_invalid()

if __name__ == "__main__":
    main()