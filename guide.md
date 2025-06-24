# Purple Teaming Lab Guide

This guide explains how to set up, run, and use the purple teaming lab for SOC operations.

## Prerequisites
- Windows host with Docker Desktop and WSL2 enabled.
- 32GB RAM, 256GB SSD (allocate ~20GB RAM and ~100GB disk to Docker).
- Internet access for pulling Docker images.
- Git installed for report management.

## Setup
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd purple-team-lab
   ```
2. Run the setup script to create configurations and pull images:
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

## Starting the Lab
1. Launch all services:
   ```bash
   chmod +x scripts/start.sh
   ./scripts/start.sh
   ```
2. Access services:
   - **Kali Linux**: 
     - SSH: `ssh root@localhost -p 2222` (password: root)
     - VNC: Connect to `localhost:5901` (password: password)
   - **Kibana**: http://localhost:5601
   - **TheHive**: http://localhost:9000 (default credentials: admin/secret)
   - **Wazuh Dashboard**: https://localhost (default credentials: admin/admin)
   - **Caldera**: http://localhost:8888 (default credentials: admin/admin)
   - **Vulnerable Targets**:
     - Metasploitable2: http://localhost:8081, SMB (localhost:4451)
     - DVWA: http://localhost:8082
     - Windows XP: SMB (localhost:4452), RDP (localhost:3389)
     - Vulnerable Web App: http://localhost:8083

## Running Exploits
1. Execute automated exploits:
   ```bash
   chmod +x scripts/exploit_vulnerabilities.sh
   ./scripts/exploit_vulnerabilities.sh
   ```
2. Exploits include:
   - **Metasploitable2**: UnrealIRCd backdoor (port 6667).
   - **DVWA**: SQL Injection (manual verification at http://localhost:8082).
   - **Windows XP**: MS08-067 NetAPI (SMB, port 445).
   - **Vulnerable Web App**: Remote File Inclusion (port 80).
   - **Atomic Red Team**: PowerShell command execution (T1059.001).
   - **Caldera**: Basic adversary operation.

## Monitoring and Detection
- **Suricata**: Logs network traffic to `/var/log/suricata/eve.json`, ingested by ELK.
- **ELK Stack**: View Suricata logs and Wazuh alerts in Kibana (http://localhost:5601).
- **Wazuh**: Monitors host activities and vulnerabilities in the dashboard (https://localhost).
- **TheHive**: Manage incidents and correlate alerts (http://localhost:9000).

## Generating Reports
1. Create a report summarizing activities:
   ```bash
   chmod +x scripts/generate_report.sh
   ./scripts/generate_report.sh
   ```
2. Reports are stored in `reports/`:
   - `activity_log.md`: Chronological log of activities.
   - `findings/`: Exploit and Suricata logs.
   - `screenshots/`: Add screenshots manually for visual evidence.

## Stopping the Lab
1. Stop and remove containers:
   ```bash
   chmod +x scripts/stop.sh
   ./scripts/stop.sh
   ```

## Troubleshooting
- **Port Conflicts**: Ensure no other services use ports 2222, 5901, 5601, 9000, 443, 8888, 8081-8083, 4451-4452, 3389.
- **Image Pull Errors**: Verify internet connectivity and Docker Hub access.
- **Service Failures**: Check logs with `docker-compose logs <service>`.

## GitHub Integration
1. Initialize a Git repository:
   ```bash
   git init
   git add .
   git commit -m "Initial purple teaming lab setup"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```
2. Push reports after each exercise:
   ```bash
   git add reports/
   git commit -m "Updated purple teaming reports"
   git push
   ```

## Security Notes
- This lab contains intentionally vulnerable systems. Run it in an isolated environment.
- Do not expose services to the public internet.
- Delete containers and volumes after use to avoid persistent vulnerabilities.