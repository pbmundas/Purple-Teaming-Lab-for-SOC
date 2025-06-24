# Purple Teaming Lab

This project sets up an automated purple teaming lab using Docker on a Windows host with WSL2. It includes open-source SOC tools for both blue team (defense) and red team (attack) operations, all interconnected and accessible from the host machine.

## Prerequisites
- Windows host with 32GB RAM, 256GB SSD.
- Docker Desktop with WSL2 backend enabled.
- WSL2 distribution (e.g., Ubuntu-22.04).
- Git installed.
- Administrator access.

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd purple-teaming-lab
   ```
2. **Run Setup Script**:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup.sh
   ```
   This creates configuration files, pulls Docker images, and sets permissions.
3. **Start the Lab**:
   ```bash
   ./scripts/start.sh
   ```
   This starts all services in the background.
4. **Access Services**:
   - Security Onion: `http://localhost:8000`
   - TheHive: `http://localhost:9000`
   - MISP: `http://localhost:8080`
   - DVWA: `http://localhost:8081`
   - OSSEC: Configure agents to connect to `localhost:1515`
   - Kali: Use RDP client to connect to `localhost:3389`
5. **Stop the Lab**:
   ```bash
   ./scripts/stop.sh
   ```
6. **Cleanup (Optional)**:
   ```bash
   ./scripts/cleanup.sh
   ```
   Removes all containers, volumes, and configuration files.

## Lab Components
- **Security Onion**: Network and host monitoring with Zeek, Suricata, and ELK Stack.
- **OSSEC**: Host-based intrusion detection system.
- **TheHive**: Incident response and case management.
- **MISP**: Threat intelligence sharing platform.
- **Kali Linux**: Red team tools for attack simulation.
- **DVWA**: Vulnerable web application for testing.

## Purple Teaming Scenarios
1. **Attack Simulation**:
   - Use Kali to launch attacks (e.g., Metasploit exploits, Nmap scans) against the DVWA container.
     ```bash
     docker exec -it kali nmap -sV dvwa
     ```
   - Attempt SQL injection or XSS attacks on DVWA (`http://localhost:8081`).
2. **Defense and Monitoring**:
   - Monitor network traffic in Security Onion (`http://localhost:8000`) using Zeek or Suricata dashboards.
   - Check OSSEC logs for host-based alerts (`localhost:1515` for agent data).
   - Create and manage incidents in TheHive (`http://localhost:9000`) based on alerts from Security Onion or OSSEC.
   - Use MISP (`http://localhost:8080`) to correlate attack indicators with threat intelligence.
3. **Integration Workflow**:
   - Security Onion sends alerts to TheHive via its API for incident creation.
   - MISP shares IOCs (Indicators of Compromise) with TheHive for correlation.
   - OSSEC agents can be configured to monitor the host and send logs to the OSSEC server.
   - Kali attacks trigger alerts in Security Onion and OSSEC, which are then analyzed in TheHive and enriched with MISP data.

## Configuration Notes
- **Port Mappings**: Each service is mapped to a unique port to avoid conflicts:
  - Security Onion: 8000 (Web UI), 514 (Syslog), 1514 (OSSEC agent)
  - OSSEC: 1515 (Server)
  - TheHive: 9000 (Web UI)
  - Elasticsearch: 9200 (TheHive backend)
  - MISP: 8080 (Web UI)
  - DVWA: 8081 (Web UI)
  - Kali: 3389 (RDP)
- **Network**: All containers are connected via a custom Docker bridge network (`purple-net`) for seamless communication.
- **Resource Limits**: Security Onion is limited to 8GB RAM to prevent resource exhaustion on the 32GB host.
- **Configuration Files**: Minimal configurations are provided in the `configs/` directory. Modify as needed for advanced setups (e.g., adding OSSEC agents, configuring MISP API keys).

## Troubleshooting
- **Image Pull Errors**: Ensure Docker Hub is accessible and no rate limits are hit. Use `docker login` if needed.
- **Port Conflicts**: Verify no other services are using the mapped ports (8000, 8080, 8081, 9000, 9200, 1514, 1515, 3389).
- **Resource Issues**: Monitor Docker Desktop resource usage. Increase WSL2 memory allocation in `.wslconfig` if needed:
  ```bash
  echo "[wsl2]" > ~/.wslconfig
  echo "memory=16GB" >> ~/.wslconfig
  wsl --shutdown
  ```
- **Service Access**: If services are inaccessible, check container logs:
  ```bash
  docker logs <container_name>
  ```
- **Kali RDP**: Ensure an RDP client (e.g., Microsoft Remote Desktop) is installed on the Windows host to access Kali at `localhost:3389`.

## Security Considerations
- **Lab Isolation**: The lab is containerized and isolated from the host network, but avoid running in a production environment.
- **DVWA Security**: DVWA is intentionally vulnerable; do not expose it to the internet.
- **Credentials**: Update default passwords in `configs/misp/config.php` and `docker-compose.yml` for production-like scenarios.
- **Data Persistence**: Configurations and data are stored in the `configs/` directory. Back up before running `cleanup.sh`.

## Extending the Lab
- Add more vulnerable applications (e.g., `juiceshop` from Docker Hub).
- Integrate additional tools like Wazuh or OpenVAS by adding services to `docker-compose.yml`.
- Configure API integrations (e.g., TheHive-MISP) for automated IOC sharing using API keys.

## Maintenance
- **Update Images**: Periodically run `docker-compose pull` to fetch the latest images.
- **Monitor Logs**: Use `docker logs <container_name>` to debug issues.
- **Backup Configurations**: Copy the `configs/` directory before cleanup.