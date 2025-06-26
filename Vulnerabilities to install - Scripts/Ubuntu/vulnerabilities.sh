#!/bin/bash

set -e

echo "[*] Updating system and installing prerequisites..."
sudo apt update && sudo apt install -y wget curl git build-essential apache2 php php-cgi openjdk-11-jdk unzip default-jdk mysql-server

echo "[*] Setting up vsftpd 2.3.4..."
cd /tmp
wget https://security.appspot.com/downloads/vsftpd-2.3.4.tar.gz
tar xzf vsftpd-2.3.4.tar.gz
cd vsftpd-2.3.4
make
sudo cp vsftpd /usr/sbin/
echo -e "listen=YES\nanonymous_enable=YES\nlocal_enable=NO\nwrite_enable=NO" | sudo tee /etc/vsftpd.conf
sudo /usr/sbin/vsftpd /etc/vsftpd.conf &

echo "[*] Installing UnrealIRCd 3.2.8.1..."
cd /tmp
wget https://downloads.sourceforge.net/project/unrealircd/Unreal3.2.8.1/unrealircd-3.2.8.1.tar.gz
tar -zxvf unrealircd-3.2.8.1.tar.gz
cd unrealircd-3.2.8.1
yes "" | ./Config
make
make install
cd ~/unreal3.2
./unreal start &

echo "[*] Configuring distcc..."
sudo apt install -y distcc
sudo sed -i 's/STARTDISTCC="false"/STARTDISTCC="true"/' /etc/default/distcc
sudo sed -i 's/ALLOWEDNETS=".*"/ALLOWEDNETS="0.0.0.0\/0"/' /etc/default/distcc
sudo systemctl enable distcc
sudo systemctl start distcc

echo "[*] Setting up vulnerable Bash for Shellshock..."
cd /tmp
wget http://security.ubuntu.com/ubuntu/pool/main/b/bash/bash_4.3-7ubuntu1_i386.deb
sudo dpkg -i bash_4.3-7ubuntu1_i386.deb || echo "[!] Ignore error if not 32-bit arch"
sudo a2enmod cgi
echo -e '#!/bin/bash\necho Content-type: text/plain\necho\necho Shellshock Test\n' | sudo tee /usr/lib/cgi-bin/test.sh
sudo chmod +x /usr/lib/cgi-bin/test.sh
sudo systemctl restart apache2

echo "[*] Setting up PHP-CGI RCE environment..."
sudo a2enmod actions
cat <<EOF | sudo tee -a /etc/apache2/sites-enabled/000-default.conf

<Directory "/var/www/html">
    Options +ExecCGI
    AddHandler php-cgi .php
    Action php-cgi /cgi-bin/php5
</Directory>
EOF
echo -e '#!/bin/bash\nexec /usr/bin/php-cgi "$@"' | sudo tee /usr/lib/cgi-bin/php5
sudo chmod +x /usr/lib/cgi-bin/php5
sudo systemctl restart apache2

echo "[*] Manually installing Apache Tomcat 7..."
cd /opt
sudo wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.109/bin/apache-tomcat-7.0.109.tar.gz
sudo tar -xzvf apache-tomcat-7.0.109.tar.gz
sudo mv apache-tomcat-7.0.109 tomcat7

sudo bash -c 'cat > /opt/tomcat7/conf/tomcat-users.xml <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="admin-gui"/>
  <user username="tomcat" password="tomcat" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOF'

sudo /opt/tomcat7/bin/startup.sh

echo ""
echo "[✔] Vulnerable services are now running:"
echo "  - vsftpd: ftp://<target-ip>:21"
echo "  - UnrealIRCd: IRC on port 6667"
echo "  - distcc: TCP port 3632"
echo "  - Shellshock CGI: http://<target-ip>/cgi-bin/test.sh"
echo "  - PHP-CGI RCE: http://<target-ip>/index.php?some_code"
echo "  - Tomcat 7: http://<target-ip>:8080/manager/html (tomcat:tomcat)"
echo ""
echo "💡 Use Kali Metasploit to test these exploits safely in your lab."

