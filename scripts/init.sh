#!/bin/bash
echo "Initializing Purple Teaming Lab..."
docker-compose up -d
echo "Configuring Kali package sources..."
docker exec kali bash -c "echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' > /etc/apt/sources.list"
echo "Installing tools in Kali..."
docker exec kali apt update
docker exec kali apt install -y nmap metasploit-framework
echo "Waiting for services to start..."
sleep 30
echo "Fixing n8n config permissions..."
docker exec n8n chmod 0600 /home/node/.n8n/config
echo "Importing n8n workflows..."
docker exec n8n n8n import:workflow --input=/home/node/workflows/network_scan_workflow.json
docker exec n8n n8n import:workflow --input=/home/node/workflows/brute_force_workflow.json
echo "Setup complete! Access n8n at http://localhost:5678, Kibana at http://localhost:5601"
