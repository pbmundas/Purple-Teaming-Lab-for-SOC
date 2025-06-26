# setup-vuln-lab.ps1 (revised)
Write-Host "[*] Creating Tools folder..."
New-Item -ItemType Directory -Path "C:\VulnLab" -Force | Out-Null
Set-Location "C:\VulnLab"

function Download-VulnApp($url, $filename) {
    Write-Host "[*] Downloading $filename..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $filename -UseBasicParsing
        Write-Host "    -> Saved as $filename"
    } catch {
        Write-Host "[!] Failed to download $filename"
    }
}

# 1. FreeFloat FTP Server 1.0
Download-VulnApp "https://github.com/0x4ndr3i/vulnserver-binaries/raw/main/FreeFloatFTPServer.exe" "FreeFloatFTPServer.exe"
if (Test-Path "FreeFloatFTPServer.exe") { Start-Process "FreeFloatFTPServer.exe" }

# 2. SLMail 5.5
Download-VulnApp "https://github.com/0x4ndr3i/vulnserver-binaries/raw/main/SLMail55Setup.exe" "SLMail55Setup.exe"
if (Test-Path "SLMail55Setup.exe") { Start-Process "SLMail55Setup.exe" }

# 3. War-FTP 1.65
Download-VulnApp "https://github.com/0x4ndr3i/vulnserver-binaries/raw/main/war-ftpd-165.exe" "war-ftpd-165.exe"
if (Test-Path "war-ftpd-165.exe") { Start-Process "war-ftpd-165.exe" }

# 4. Easy RM to MP3 Converter
Download-VulnApp "https://github.com/0x4ndr3i/vulnserver-binaries/raw/main/EasyRMtoMP3Converter.exe" "EasyRMtoMP3Converter.exe"
if (Test-Path "EasyRMtoMP3Converter.exe") { Start-Process "EasyRMtoMP3Converter.exe" }

# 5. Vulnserver
Download-VulnApp "https://github.com/stephenbradshaw/vulnserver/raw/master/vulnserver.exe" "vulnserver.exe"
if (Test-Path "vulnserver.exe") { Start-Process "vulnserver.exe" }

Write-Host ""
Write-Host "Vulnerable applications have been downloaded and launched."
Write-Host "You can now test exploitation using Metasploit from your Kali Linux box."
Write-Host ""
Write-Host "Services available:"
Write-Host "  - FreeFloat FTP: port 21"
Write-Host "  - SLMail: port 110 (POP3)"
Write-Host "  - WarFTP: port 21"
Write-Host "  - Vulnserver: port 9999"
Write-Host ""
Write-Host "IMPORTANT: Only use this in an isolated lab environment!"
