#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install dependencies for builds and services
apt-get install -y build-essential libpam0g-dev git apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php nfs-kernel-server nfs-common ufw nmap

# Flush firewall for lab (disable in production!)
iptables --flush
ufw allow from any to any
ufw --force enable

# Install vulnerable vsftpd 2.3.4
git clone https://github.com/DoctorKisow/vsftpd-2.3.4.git
cd vsftpd-2.3.4
chmod +x vsf_findlibs.sh
sed -i 's/LIBS =/LIBS = -lpam/' Makefile  # Add -lpam to Makefile
make
install -v -d -m 0755 /var/ftp/empty
install -v -d -m 0755 /home/ftp
groupadd -g 47 vsftpd
groupadd -g 48 ftp
useradd -c "vsftpd User" -d /dev/null -g vsftpd -s /bin/false -u 47 vsftpd
useradd -c anonymous_user -d /home/ftp -g ftp -s /bin/false -u 48 ftp
install -v -m 755 vsftpd /usr/sbin/vsftpd
install -v -m 644 vsftpd.8 /usr/share/man/man8
install -v -m 644 vsftpd.conf.5 /usr/share/man/man5
install -v -m 644 vsftpd.conf /etc
cd ..
/usr/sbin/vsftpd &  # Start vsftpd

# Install DVWA
git clone https://github.com/digininja/DVWA.git /var/www/html/DVWA
cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
sed -i "s/'db_user'     = 'dvwa';/'db_user'     = 'root';/" /var/www/html/DVWA/config/config.inc.php
sed -i "s/'db_password' = 'p@ssw0rd';/'db_password' = 'root';/" /var/www/html/DVWA/config/config.inc.php  # Set weak password for lab
chown -R www-data:www-data /var/www/html/DVWA
chmod -R 755 /var/www/html/DVWA
systemctl restart apache2
mysql -u root -e "CREATE DATABASE dvwa;"
mysql -u root -e "CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
mysql -u root -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Setup vulnerable rsync
echo "motd file = /etc/rsyncd.motd" > /etc/rsyncd.conf
echo "lock file = /var/run/rsync.lock" >> /etc/rsyncd.conf
echo "log file = /var/log/rsyncd.log" >> /etc/rsyncd.conf
echo "pid file = /var/run/rsyncd.pid" >> /etc/rsyncd.conf
echo "" >> /etc/rsyncd.conf
echo "[files]" >> /etc/rsyncd.conf
echo "path = /" >> /etc/rsyncd.conf
echo "comment = Remote file share." >> /etc/rsyncd.conf
echo "uid = 0" >> /etc/rsyncd.conf
echo "gid = 0" >> /etc/rsyncd.conf
echo "read only = no" >> /etc/rsyncd.conf
echo "list = yes" >> /etc/rsyncd.conf
systemctl enable rsync
systemctl start rsync

# Setup vulnerable NFS
echo "/home *(rw,sync,no_root_squash)" >> /etc/exports
echo "/ *(rw,sync,no_root_squash)" >> /etc/exports
systemctl restart nfs-kernel-server

# Create vulnerable setuid binary
echo "#include <stdlib.h>" > /home/exec.c
echo "#include <stdio.h>" >> /home/exec.c
echo "#include <unistd.h>" >> /home/exec.c
echo "#include <string.h>" >> /home/exec.c
echo "" >> /home/exec.c
echo "int main(int argc, char *argv[]){" >> /home/exec.c
echo "printf(\"%s,%d\\n\", \"USER ID:\",getuid());" >> /home/exec.c
echo "printf(\"%s,%d\\n\", \"EXEC ID:\",geteuid());" >> /home/exec.c
echo "printf(\"Enter OS command:\");" >> /home/exec.c
echo "char line[100];" >> /home/exec.c
echo "fgets(line,sizeof(line),stdin);" >> /home/exec.c
echo "line[strlen(line) - 1] = ' ';" >> /home/exec.c
echo "char * s = line;" >> /home/exec.c
echo "char * command[5];" >> /home/exec.c
echo "int i = 0;" >> /home/exec.c
echo "while(s){" >> /home/exec.c
echo "command[i] = strsep(&s,\" \");" >> /home/exec.c
echo "if(command[i] == NULL) break;" >> /home/exec.c
echo "i++;" >> /home/exec.c
echo "}" >> /home/exec.c
echo "command[i] = NULL;" >> /home/exec.c
echo "execvp(command[0],command);" >> /home/exec.c
echo "return 0;" >> /home/exec.c
echo "}" >> /home/exec.c
gcc /home/exec.c -o /home/exec
chown root:root /home/exec
chmod 4755 /home/exec  # Setuid bit

# Enable password auth for SSH (vulnerable config)
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart ssh

# Create weak credentials files for discovery
echo "user2:test" > /root/user2.txt
echo "test:password" > /tmp/creds.txt
echo "test:test" > /tmp/mypassword.txt

echo "Vulnerable software installed. Access DVWA at http://localhost/DVWA (setup database via /setup.php). Test exploits in isolated lab only."
