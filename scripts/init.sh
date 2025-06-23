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
