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
   - Use Kali