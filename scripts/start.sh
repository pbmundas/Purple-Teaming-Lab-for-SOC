#!/bin/bash

echo "Starting Purple Teaming Lab..."
docker-compose up -d
echo "Lab started! Access services at:"
echo "- Kali: SSH (localhost:2222), VNC (localhost:5901)"
echo "- Kibana: http://localhost:5601"
echo "- TheHive: http://localhost:9000"
echo "- Wazuh: https://localhost"
echo "- Caldera: http://localhost:8888"
echo "- Vulnerable Targets:"
echo "  - Metasploitable2: http://localhost:8081, SMB (localhost:4451)"
echo "  - DVWA: http://localhost:8082"
echo "  - Windows XP: SMB (localhost:4452), RDP (localhost:3389)"
echo "  - Vuln Web: http://localhost:8083"