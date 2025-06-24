# Purple Teaming Lab

A Docker-based purple teaming lab for SOC operations, integrating offensive and defensive tools for automated adversary emulation and detection.

## Features
- **Offensive Tools**: Kali Linux with Metasploit, Atomic Red Team, Caldera.
- **Defensive Tools**: Suricata, ELK Stack, TheHive, Wazuh.
- **Vulnerable Targets**: Metasploitable2, DVWA, Windows XP (MS08-067), custom vulnerable web app.
- **Automation**: Scripts for setup, exploitation, and reporting.
- **Integration**: Interconnected services with logs flowing to ELK and TheHive.
- **GitHub-Ready**: Structured reports for activity tracking.

## Requirements
- Windows host with Docker Desktop and WSL2.
- 32GB RAM, 256GB SSD.
- Internet access for Docker Hub.

## Quick Start
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd purple-team-lab
   ```
2. Set up the lab:
   ```bash
   ./scripts/setup.sh
   ```
3. Start the lab:
   ```bash
   ./scripts/start.sh
   ```
4. Run exploits:
   ```bash
   ./scripts/exploit_vulnerabilities.sh
   ```
5. Generate reports:
   ```bash
   ./scripts/generate_report.sh
   ```
6. Stop the lab:
   ```bash
   ./scripts/stop.sh
   ```

## Documentation
See [guide.md](guide.md) for detailed setup and usage instructions.

## License
MIT License