#!/bin/bash

echo "Generating report..."

# Copy logs from containers
docker cp kali:/root/exploit_log.txt reports/findings/exploit_log_$(date +%F).txt
docker cp suricata:/var/log/suricata/eve.json reports/findings/suricata_log_$(date +%F).json

# Append to activity log
cat <<EOF >> reports/activity_log.md
## Exploitation Run - $(date)
- Ran automated exploits via Metasploit.
- Executed Atomic Red Team test (T1059.001).
- Started Caldera operation (TestOp).
- Suricata logs captured in findings/suricata_log_$(date +%F).json.
- Exploit logs saved in findings/exploit_log_$(date +%F).txt.
EOF

echo "Report generated in reports/activity_log.md"