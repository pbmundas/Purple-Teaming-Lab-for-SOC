#!/bin/bash
set -e

echo "Starting Purple Teaming Lab..."
docker-compose up -d

echo "Lab started. Access services at:"
echo "- Security Onion: http://localhost:8000"
echo "- TheHive: http://localhost:9000"
echo "- MISP: http://localhost:8080"
echo "- DVWA: http://localhost:8081"
echo "- OSSEC: Port 1515 (agent configuration)"
echo "- Kali: RDP to localhost:3389"
