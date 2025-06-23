# Automated Purple Teaming Lab with n8n and Docker

A self-contained purple teaming lab for automated attack simulation and analysis using n8n, Kali Linux, ELK, Zeek, Suricata, and Metasploitable 2, running on Docker Desktop for Windows.

## Prerequisites
- Windows 10/11 with WSL 2 enabled
- Docker Desktop installed and running
- Git installed

## Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/purple-teaming-lab.git
   cd purple-teaming-lab
   ```
2. Run the initialization script:
   ```bash
   bash scripts/init.sh
   ```
3. Access the services:
   - n8n: http://localhost:5678
   - Kibana: http://localhost:5601

## Documentation
- [Installation Guide](install_guide.md)
- [Usage Guide](usage_guide.md)
- [Troubleshooting Guide](troubleshooting_guide.md)

## License
MIT