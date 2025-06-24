#!/bin/bash
set -e

echo "Setting up Purple Teaming Lab..."

# Create necessary directories
mkdir -p configs/securityonion configs/ossec configs/thehive configs/misp

# Create minimal configuration files
cat <<EOF > configs/securityonion/so-config.yml
# Security Onion configuration
node:
  type: standalone
EOF

cat <<EOF > configs/ossec/ossec.conf
<ossec_config>
  <global>
    <email_notification>no</email_notification>
  </global>
  <syscheck>
    <frequency>7200</frequency>
    <directories check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
  </syscheck>
</ossec_config>
EOF

cat <<EOF > configs/thehive/application.conf
play.http.secret.key="changeme"
db.provider=org.elasticsearch.ElasticsearchDatabase
db.elasticsearch.uri="http://elasticsearch:9200"
EOF

cat <<EOF > configs/misp/config.php
<?php
\$CONFIG = [
    'MISP' => [
        'baseurl' => 'http://localhost:8080',
        'uuid' => 'random-uuid-here',
    ],
    'Security' => [
        'salt' => 'random-salt-here',
    ],
];
EOF

# Pull Docker images
echo "Pulling Docker images..."
docker-compose pull

# Set permissions for Docker socket
sudo chmod 666 /var/run/docker.sock

echo "Setup complete. Run './scripts/start.sh' to start the lab."
