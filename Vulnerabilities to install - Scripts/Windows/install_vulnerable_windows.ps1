# Set execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install AD DS and create vulnerable domain
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName "lab.local" -DomainNetbiosName "LAB" -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$true -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force)

# Add vulnerable users and groups
net user user1 Passw0rd! /ADD /DOMAIN
net group "Domain Admins" user1 /add
net user user2 Passw0rd! /ADD /DOMAIN
setspn -s http/server.lab.local:80 user1  # Vulnerable SPN for Kerberoasting

# Install Git for cloning
choco install git -y  # Assume Chocolatey is installed; if not, install it first: iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install BadBlood to introduce AD vulnerabilities
git clone https://github.com/davidprowe/BadBlood.git C:\BadBlood
cd C:\BadBlood
.\Invoke-BadBlood.ps1  # Runs with default config; creates random vulnerable objects

# Install XAMPP for DVWA
Invoke-WebRequest -Uri "https://www.apachefriends.org/xampp-files/8.0.28/xampp-windows-x64-8.0.28-0-VS16-installer.exe" -OutFile "C:\xampp-installer.exe"
Start-Process "C:\xampp-installer.exe" -ArgumentList "/S" -Wait  # Silent install
cd "C:\xampp\htdocs"
git clone https://github.com/digininja/DVWA.git
Copy-Item -Path "DVWA\config\config.inc.php.dist" -Destination "DVWA\config\config.inc.php"
(Get-Content "DVWA\config\config.inc.php") -replace "'db_user'     = 'dvwa';", "'db_user'     = 'root';" | Set-Content "DVWA\config\config.inc.php"
(Get-Content "DVWA\config\config.inc.php") -replace "'db_password' = 'p@ssw0rd';", "'db_password' = '';" | Set-Content "DVWA\config\config.inc.php"  # Empty password for lab vuln
C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE dvwa;"
Start-Process "C:\xampp\xampp-control.exe"  # Start XAMPP

# Install vulnerable IIS and FTP
Install-WindowsFeature Web-Server, Web-Ftp-Server -IncludeManagementTools
Import-Module WebAdministration
New-WebAppPool -Name "VulnPool"
New-Website -Name "VulnSite" -Port 80 -PhysicalPath "C:\inetpub\wwwroot" -ApplicationPool "VulnPool"
New-FtpSite -Name "VulnFTP" -Port 21 -PhysicalPath "C:\inetpub\wwwroot"
Set-ItemProperty "IIS:\Sites\VulnFTP" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0  # Disable SSL for vuln
Restart-Service W3SVC
Restart-Service FTPSVC

# Create weak files for discovery
"test:password" | Out-File -FilePath "C:\creds.txt"

Write-Host "Vulnerable software installed. Reboot may be needed for AD. Access DVWA at http://localhost/DVWA (setup via /setup.php). Test in isolated lab only."
