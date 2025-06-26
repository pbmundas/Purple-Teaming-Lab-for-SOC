# setup-vuln-lab.ps1
# Vulnerable Windows application setup script for Metasploit labs (Run as Admin)

Write-Host "[*] Creating Tools folder..."
New-Item -ItemType Directory -Path "C:\VulnLab" -Force | Out-Null
Set-Location "C:\VulnLab"

function Download-VulnApp($url, $filename) {
    Write-Host "[*] Downloading $filename..."
    Invoke-WebRequest -Uri $url -OutFile $filename
    Write-Host "    -> Saved as $filename"
}

# 1. FreeFloat FTP Server 1.0 (USER buffer overflow)
Download-VulnApp "https://www.exploit-db.com/apps/4dc355f1b7b7c03cd52e8ad4d32f8e16-FreeFloatFTPServer.exe" "FreeFloatFTPServer.exe"
Start-Process "FreeFloatFTPServer.exe"

# 2. SLMail 5.5 (POP3 overflow)
Download-VulnApp "https://www.exploit-db.com/apps/0a393fa7d0bb7ccaf0d057d5c7d4e44a-SLMail55Setup.exe" "SLMail55Setup.exe"
Start-Process "SLMail55Setup.exe"

# 3. War-FTP 1.65 (USER overflow)
Download-VulnApp "https://www.exploit-db.com/apps/9c7a66e188afe5bb7e9a7e9ebc119b4d-war-ftpd-165.exe" "war-ftpd-165.exe"
Start-Process "war-ftpd-165.exe"

# 4. Easy RM to MP3 Converter (file format exploit)
Download-VulnApp "https://www.exploit-db.com/apps/e9e67e19d1bc9999d1dc6ef12e01f975-EasyRMtoMP3Converter.exe" "EasyRMtoMP3Converter.exe"
Start-Process "EasyRMtoMP3Converter.exe"

# 5. Vulnserver (custom SEH overflow lab)
Download-VulnApp "https://github.com/stephenbradshaw/vulnserver/raw/master/vulnserver.exe" "vulnserver.exe"
Start-Process "vulnserver.exe"

Write-Host ""
Write-Host " Vulnerable applications have been downloaded and launched."
Write-Host "You can now test exploitation using Metasploit from your Kali Linux box."
Write-Host ""
Write-Host "Services available:"
Write-Host "  - FreeFloat FTP: port 21"
Write-Host "  - SLMail: port 110 (POP3)"
Write-Host "  - WarFTP: port 21"
Write-Host "  - Vulnserver: port 9999"
Write-Host ""
Write-Host "IMPORTANT: Only use this in an isolated lab environment!"
