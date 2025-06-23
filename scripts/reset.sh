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
