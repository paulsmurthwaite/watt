# WATT Attacker Environment
This repository contains configuration files, scripts, and tooling for the Wireless Attack Test Toolkit (WATT) environment.  It supports the Wireless Security Testing Toolkit (WSTT) project by generating realistic, controlled wireless attack scenarios.

## Repository Structure
- attacks/ – Per-threat scenario folders for each implemented attack
- scripts/ – Core AP launch, teardown, and service control scripts
- hostapd.conf – Default open or WPA2 rogue AP configuration
- dnsmasq.conf – DHCP configuration for IP and DNS assignment

### Example:
```
attacks/
  T004_evil_twin/
  T005_open_rogue_ap/
  T007_deauth_flood/

scripts/
  start-ap.sh
  stop-ap.sh
  hostapd.conf
  dnsmasq.conf
```

---

## Host System Requirements
- Ubuntu 22.04 LTS (or compatible)
- Alfa AWUS036ACM wireless adapter (AP mode capable)
- Tools: ```hostapd```, ```dnsmasq```, ```iptables```, ```mdk4```, ```aircrack-ng```, ```bettercap```, ```tcpdump```, ```macchanger```

---

## Scenario Execution
Use the provided scripts to start and stop rogue APs in either NAT (internet passthrough) or isolated mode:

- Start open rogue AP with internet passthrough:
```sudo ./start-ap.sh nat```
- Start AP with no internet access:
```sudo ./start-ap.sh```
- Stop all services and restore system state:
```sudo ./stop-ap.sh```

---

## Each attack scenario in attacks/ contains:
- Config files
- Attack launch scripts (attack.sh)
- Teardown scripts (stop.sh)
- Optional logs and documentation

--- 

## Integration with WSTT
- This attacker environment operates independently from WSTT
- WSTT captures traffic in monitor mode for offline analysis
- No real-time coordination or defence interaction required

---

## Notes
- systemd-resolved is disabled when running AP mode to avoid DNS conflicts
- NetworkManager is stopped to prevent interface conflicts
- IP forwarding and NAT rules are dynamically applied
- Client devices must manually connect to AP during test scenarios

---

## License
- MIT License or project-specific license