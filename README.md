# Wireless Attack Testing Toolkit (WATT)

## Overview
WATT contains the specialized scripts and configurations required to generate realistic, controlled wireless attack scenarios. It serves as the "Attacker" environment in the research lab setup.

## Engineering Philosophy
- **Rigor & Reliability:** Tested against 8 distinct threat classes (passive, active, stateful, and high-volume) with a 100% detection success rate in the associated analysis engine.
- **Independent Operation:** Operates as a standalone environment to maintain laboratory integrity during monitor-mode capture sessions.
- **Dynamic Networking:** Utilises automated IP forwarding and NAT rules to simulate internet-connected rogue APs.

## Key Features
- **Attack Library:** Per-threat folders containing specific launch and teardown scripts (e.g., Evil Twin, Deauth Flood).
- **Service Orchestration:** Integrated control of `hostapd`, `dnsmasq`, `mdk4`, and `bettercap`.
- **Lab Hardware:** Specifically tuned for Ubuntu 22.04 LTS and Alfa monitor-mode adapters.

---
## Project Ecosystem
*See the [Core Toolkit (WSTT)](https://github.com/paulsmurthwaite/wstt) for the main analysis engine.*