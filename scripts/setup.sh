#!/bin/bash

echo "Setting up Purple Teaming Lab..."

# Create directories
mkdir -p configs/suricata configs/wazuh configs/thehive reports/findings reports/screenshots

# Create Suricata config
cat > configs/suricata/suricata.yaml <<EOF
%YAML 1.1
---
vars:
  address-groups:
    HOME_NET: "[172.18.0.0/16]"
    EXTERNAL_NET: "!$HOME_NET"
logging:
  outputs:
    - eve-log:
        enabled: yes
        filetype: regular
        filename: eve.json
EOF

# Create Wazuh config
cat > configs/wazuh/ossec.conf <<EOF
<ossec_config>
  <global>
    <jsonout_output>yes</jsonout_output>
  </global>
  <syscheck>
    <frequency>43200</frequency>
    <directories>/etc,/usr/bin,/usr/sbin</directories>
  </syscheck>
</ossec_config>
EOF

# Create TheHive config
cat > configs/thehive/application.conf <<EOF
play.http.secret.key="changeme"
db {
  provider: h2
  url: "jdbc:h2:/opt/thehive/db/thehive"
}
EOF

# Create report templates
cat > reports/README.md <<EOF
# Purple Teaming Lab Report
This repository contains reports and findings from the purple teaming lab exercises.

## Structure
- **activity_log.md**: Detailed log of all activities.
- **findings/**: Individual findings reports.
- **screenshots/**: Screenshots of exploits and detections.
EOF

cat > reports/activity_log.md <<EOF
# Activity Log
## Setup
- Lab initialized on $(date)
EOF

# Pull Docker images
docker-compose pull

echo "Setup complete! Run './scripts/start.sh' to start the lab."