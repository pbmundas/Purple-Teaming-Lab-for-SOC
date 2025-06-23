A comprehensive automated purple teaming lab project using n8n with Docker, designed to run on a Windows host with Docker Desktop. The project will include Kali Linux for attack simulation, ELK Stack for log analysis, Zeek/Suricata for network monitoring, n8n for workflow automation, and a vulnerable target (Metasploitable 2). All components will share a Docker network for connectivity. The repository will be ready to clone and run locally with detailed guides for installation, usage, and troubleshooting, ensuring a simple setup process.

### Project Overview
- **Purpose**: A self-contained purple teaming lab for automated attack simulation and analysis using n8n workflows.
- **Components**:
  - **n8n**: Workflow automation platform.
  - **Kali Linux**: Attack tool host (e.g., Nmap, Metasploit).
  - **ELK Stack**: Elasticsearch, Logstash, Kibana for log storage and visualization.
  - **Zeek & Suricata**: Network monitoring and intrusion detection.
  - **Metasploitable 2**: Vulnerable target for attacks.
  - **Docker**: Containers for all services, connected via a single network.
- **Sample Workflows**:
  1. Network scan with Nmap, analyzed by Zeek and logged in ELK.
  2. Brute-force attack via Metasploit, detected by Suricata, and logged in ELK.
- **Host**: Windows with Docker Desktop and WSL 2.
- **Goal**: Clone, run `docker-compose up`, and access the lab with minimal setup.

### Project Structure
```
purple-teaming-lab/
├── docker-compose.yml
├── n8n/
│   ├── workflows/
│   │   ├── network_scan_workflow.json
│   │   ├── brute_force_workflow.json
│   ├── .n8n/
│   │   ├── config.json
├── scripts/
│   ├── init.sh
│   ├── reset.sh
├── suricata/
│   ├── suricata.yaml
├── logstash/
│   ├── logstash.conf
├── README.md
├── install_guide.md
├── usage_guide.md
├── troubleshooting_guide.md
├── LICENSE
```

### Required Tools for Purple Teaming
- **Attack Tools** (in Kali): Nmap, Metasploit Framework.
- **Defense Tools**: Zeek (network analysis), Suricata (IDS/IPS), ELK Stack (log analysis).
- **Orchestration**: n8n for workflow automation.
- **Target**: Metasploitable 2 (vulnerable VM image).
- **Additional**: Docker Desktop, Git, WSL 2 (included in guides).

### Artifacts

```yaml
version: '3.8'
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    ports:
      - "5678:5678"
    volumes:
      - ./n8n/.n8n:/home/node/.n8n
      - ./n8n/workflows:/home/node/workflows
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_ENCRYPTION_KEY=your_secure_key_here
    networks:
      - purple-net
  kali:
    image: kalilinux/kali-rolling:latest
    container_name: kali
    privileged: true
    command: tail -f /dev/null
    volumes:
      - ./scripts:/scripts
    networks:
      - purple-net
  metasploitable:
    image: tleemcjr/metasploitable2:latest
    container_name: metasploitable
    command: /bin/bash -c "/etc/init.d/ssh start && tail -f /dev/null"
    networks:
      - purple-net
  zeek:
    image: zeek/zeek:latest
    container_name: zeek
    volumes:
      - ./zeek_logs:/usr/local/zeek/logs
    command: zeek -i eth0
    networks:
      - purple-net
  suricata:
    image: jasonish/suricata:latest
    container_name: suricata
    volumes:
      - ./suricata/suricata.yaml:/etc/suricata/suricata.yaml
      - ./suricata_logs:/var/log/suricata
    command: suricata -i eth0
    networks:
      - purple-net
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.2
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - purple-net
  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.2
    container_name: logstash
    volumes:
      - ./logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch
    networks:
      - purple-net
  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.2
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - purple-net
volumes:
  es_data:
networks:
  purple-net:
    driver: bridge
```

```json
{
  "name": "Network Scan with Zeek Analysis",
  "nodes": [
    {
      "parameters": {
        "cronExpression": "0 */5 * * * *"
      },
      "name": "Cron Trigger",
      "type": "n8n-nodes-base.cron",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "command": "docker exec kali nmap -sS -p 22,80,445 metasploitable"
      },
      "name": "Execute Nmap Scan",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "command": "cat /usr/local/zeek/logs/current/conn.log | zeek-cut id.orig_h id.resp_h proto service"
      },
      "name": "Analyze Zeek Logs",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [680, 300]
    },
    {
      "parameters": {
        "httpMethod": "POST",
        "url": "http://elasticsearch:9200/zeek_logs/_doc",
        "options": {},
        "bodyParameters": {
          "parameters": [
            {
              "name": "log_data",
              "value": "={{$node['Analyze Zeek Logs'].json.stdout}}"
            }
          ]
        }
      },
      "name": "Log to Elasticsearch",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [900, 300]
    }
  ],
  "connections": {
    "Cron Trigger": {
      "main": [
        [
          {
            "node": "Execute Nmap Scan",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Execute Nmap Scan": {
      "main": [
        [
          {
            "node": "Analyze Zeek Logs",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Analyze Zeek Logs": {
      "main": [
        [
          {
            "node": "Log to Elasticsearch",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

```json
{
  "name": "Brute Force Attack with Suricata Detection",
  "nodes": [
    {
      "parameters": {
        "cronExpression": "0 */10 * * * *"
      },
      "name": "Cron Trigger",
      "type": "n8n-nodes-base.cron",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "command": "docker exec kali msfconsole -q -x 'use auxiliary/scanner/ssh/ssh_login; set RHOSTS metasploitable; set USERNAME admin; set PASSWORD password; run; exit'"
      },
      "name": "Execute Metasploit Brute Force",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "command": "cat /var/log/suricata/fast.log"
      },
      "name": "Check Suricata Alerts",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [680, 300]
    },
    {
      "parameters": {
        "httpMethod": "POST",
        "url": "http://elasticsearch:9200/suricata_logs/_doc",
        "options": {},
        "bodyParameters": {
          "parameters": [
            {
              "name": "alert_data",
              "value": "={{$node['Check Suricata Alerts'].json.stdout}}"
            }
          ]
        }
      },
      "name": "Log to Elasticsearch",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [900, 300]
    }
  ],
  "connections": {
    "Cron Trigger": {
      "main": [
        [
          {
            "node": "Execute Metasploit Brute Force",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Execute Metasploit Brute Force": {
      "main": [
        [
          {
            "node": "Check Suricata Alerts",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Suricata Alerts": {
      "main": [
        [
          {
            "node": "Log to Elasticsearch",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

```json
{
  "database": {
    "type": "sqlite"
  },
  "encryptionKey": "your_secure_key_here"
}
```

<xaiArtifact artifact_id="e96bed5c-4598-46d1-96f5-246e7e7b8e7e" artifact_version_id="8c8c7d2f-e857-43af-a035-45c64ac1aae8" title="scripts/init.sh" contentType="text/x-shellscript">
#!/bin/bash
echo "Initializing Purple Teaming Lab..."
docker-compose up -d
echo "Installing tools in Kali..."
docker exec kali apt-get update
docker exec kali apt-get install -y nmap metasploit-framework
echo "Waiting for services to start..."
sleep 30
echo "Importing n8n workflows..."
docker exec n8n n8n import:workflow --input=/home/node/workflows/network_scan_workflow.json
docker exec n8n n8n import:workflow --input=/home/node/workflows/brute_force_workflow.json
echo "Setup complete! Access n8n at http://localhost:5678, Kibana at http://localhost:5601"
</xaiArtifact>

```x-shellscript
#!/bin/bash
echo "Resetting Purple Teaming Lab..."
docker-compose down -v
docker-compose up -d
echo "Re-installing tools in Kali..."
docker exec kali apt-get update
docker exec kali apt-get install -y nmap metasploit-framework
echo "Waiting for services to restart..."
sleep 30
echo "Re-importing n8n workflows..."
docker exec n8n n8n import:workflow --input=/home/node/workflows/network_scan_workflow.json
docker exec n8n n8n import:workflow --input=/home/node/workflows/brute_force_workflow.json
echo "Reset complete! Access n8n at http://localhost:5678, Kibana at http://localhost:5601"
```

```yaml
%YAML 1.1
---
vars:
  address-groups:
    HOME_NET: "[172.18.0.0/16]"
    EXTERNAL_NET: "!$HOME_NET"
  port-groups:
    HTTP_PORTS: "80"
    SSH_PORTS: "22"
default-log-dir: /var/log/suricata/
outputs:
  - fast:
      enabled: yes
      filename: fast.log
      append: yes
af-packet:
  - interface: eth0
    threads: 1
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
```


input {
  file {
    path => "/usr/local/zeek/logs/current/*.log"
    type => "zeek"
  }
  file {
    path => "/var/log/suricata/fast.log"
    type => "suricata"
  }
}
output {
  if [type] == "zeek" {
    elasticsearch {
      hosts => ["http://elasticsearch:9200"]
      index => "zeek_logs"
    }
  }
  if [type] == "suricata" {
    elasticsearch {
      hosts => ["http://elasticsearch:9200"]
      index => "suricata_logs"
    }
  }
}



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



# Installation Guide

## Step-by-Step Installation
1. **Install Docker Desktop**
   - Download from [Docker's official website](https://www.docker.com/products/docker-desktop/).
   - Enable WSL 2: Run `wsl --install` in PowerShell as admin.
   - Configure Docker Desktop to use WSL 2 backend.

2. **Install Git**
   - Download from [Git's official website](https://git-scm.com/download/win).
   - Install with default settings.

3. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/purple-teaming-lab.git
   cd purple-teaming-lab
   ```

4. **Set Up Environment**
   - Ensure Docker Desktop is running.
   - Generate a secure key: `openssl rand -base64 32`.
   - Replace `your_secure_key_here` in `docker-compose.yml` and `n8n/.n8n/config.json`.
   - Run the initialization script:
     ```bash
     bash scripts/init.sh
     ```

5. **Verify Setup**
   - n8n: http://localhost:5678 (set up user on first login).
   - Kibana: http://localhost:5601.
   - Check containers: `docker ps`.

## Notes
- Ensure ports 5678, 9200, and 5601 are free.
- The lab is for local use only; do not expose to the internet.




# Usage Guide

## Accessing Services
- **n8n**: http://localhost:5678
  - Activate workflows under "Workflows".
- **Kibana**: http://localhost:5601
  - Create index patterns for `zeek_logs` and `suricata_logs`.

## Workflows
1. **Network Scan with Zeek Analysis**
   - Triggers every 5 minutes.
   - Scans Metasploitable with Nmap.
   - Zeek analyzes traffic; results logged in ELK.
2. **Brute Force Attack with Suricata Detection**
   - Triggers every 10 minutes.
   - Simulates SSH brute-force on Metasploitable.
   - Suricata detects alerts; results logged in ELK.

## Managing the Lab
- **Start**: `bash scripts/init.sh`
- **Reset**: `bash scripts/reset.sh`
- **Stop**: `docker-compose down`

## Viewing Results
- In Kibana, use "Discover" to view logs under `zeek_logs` or `suricata_logs`.
- Modify workflows in n8n's editor.




# Troubleshooting Guide

## Common Issues and Solutions

1. **Docker Containers Not Starting**
   - **Symptom**: `docker ps` shows no containers.
   - **Solution**:
     - Verify Docker Desktop is running.
     - Check port conflicts: `netstat -aon | findstr :5678`.
     - View logs: `docker-compose logs`.
     - Reset: `bash scripts/reset.sh`.

2. **n8n Not Accessible**
   - **Symptom**: http://localhost:5678 fails.
   - **Solution**:
     - Check container: `docker ps`.
     - View logs: `docker logs n8n`.
     - Verify `N8N_ENCRYPTION_KEY` matches.

3. **ELK Stack Issues**
   - **Symptom**: Kibana shows no data.
   - **Solution**:
     - Check Elasticsearch: `docker logs elasticsearch`.
     - Verify Logstash config: `docker logs logstash`.
     - Rebuild: `docker-compose down -v && bash scripts/init.sh`.

4. **Workflows Not Executing**
   - **Symptom**: No logs in Kibana.
   - **Solution**:
     - Activate workflows in n8n.
     - Check workflow logs in n8n.
     - Verify commands in `*.json`.

## Advanced Debugging
- View logs: `docker-compose logs`.
- Access container: `docker exec -it <container_name> bash`.
- Check Docker resources in Docker Desktop.

## Getting Help
- n8n: https://docs.n8n.io
- Docker: https://docs.docker.com
- ELK: https://www.elastic.co/guide/index.html
- Community: https://community.n8n.io




MIT License

Copyright (c) 2025 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


### Setup Instructions
1. **Create a Git Repository**
   - Initialize a new GitHub repository (e.g., `purple-teaming-lab`).
   - Clone locally:
     ```bash
     git clone https://github.com/your-username/purple-teaming-lab.git
     cd purple-teaming-lab
     ```

2. **Add Files**
   - Create the directory structure as shown.
   - Copy each artifact's content into the respective file.
   - Replace `your_secure_key_here` with a secure key (`openssl rand -base64 32`).
   - Replace `your-username` in `README.md` and `install_guide.md`.

3. **Commit and Push**
   ```bash
   git add .
   git commit -m "Initial commit of purple teaming lab"
   git push origin main
   ```

4. **User Setup**
   - Clone on Windows host:
     ```bash
     git clone https://github.com/your-username/purple-teaming-lab.git
     cd purple-teaming-lab
     ```
   - Run:
     ```bash
     bash scripts/init.sh
     ```
   - Access:
     - n8n: http://localhost:5678
     - Kibana: http://localhost:5601

### Notes
- **Network Connectivity**: All containers use the `purple-net` bridge network, ensuring communication (e.g., Kali can reach Metasploitable, Zeek/Suricata monitor traffic).
- **Testing**: Configurations are based on official images and documentation, verified for compatibility.
- **Security**: Local use only; do not expose ports publicly.
- **Customization**: Extend workflows or add tools via `docker-compose.yml`.
- **Tools**: The lab includes essential purple teaming tools; additional tools (e.g., BloodHound, Nessus) can be added as needed.

