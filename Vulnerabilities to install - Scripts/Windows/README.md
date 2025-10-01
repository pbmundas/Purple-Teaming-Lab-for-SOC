### install_vulnerable_windows.ps1
PowerShell Script for Windows: Install Vulnerable Software for Purple Team Lab
This script installs and configures vulnerable software on Windows (Server 2016+ or 10+). It includes:

Active Directory Domain Services (AD DS) setup as a vulnerable domain.
BadBlood (introduces thousands of vulnerable objects, users, groups, permissions; exploitable via Metasploit AD modules like auxiliary/gather/ldap_query or Kerberoasting exploits).
DVWA via XAMPP (intentionally vulnerable web app, as above).
Vulnerable IIS/FTP (old config, exploitable via Metasploit's IIS/FTP modules like exploit/windows/iis/iis_webdav_scstoragepathfromurl).

Run as Administrator (e.g., powershell -ExecutionPolicy Bypass -File install_vulnerable_windows.ps1). Assumes a fresh install; test in a VM. Derived from tested GitHub and lab sources.


### setup-vuln-lab.ps1
Here’s a Windows equivalent setup to your Ubuntu vulnerabilities.sh lab — a curated list of vulnerable Windows applications and corresponding Metasploit modules, intended for lab use only (e.g., in VirtualBox or Hyper-V).

Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup-vuln-lab.ps1


🧨 Intentionally Vulnerable Windows Applications for Metasploit Practice
| Software                             | Vulnerability / Exploit | Metasploit Module                                   |
| ------------------------------------ | ----------------------- | --------------------------------------------------- |
| **EasyRM to MP3 Converter**          | SEH Buffer Overflow     | `exploit/windows/fileformat/easy_rm_to_mp3`         |
| **Kiwi Syslog Server v8.3.4**        | SEH Stack Overflow      | `exploit/windows/misc/kiwi_syslog_server`           |
| **FreeFloat FTP Server 1.0**         | Buffer Overflow (USER)  | `exploit/windows/ftp/freefloatftp_user`             |
| **SLMail 5.5**                       | POP3 Buffer Overflow    | `exploit/windows/pop3/slmail_seh`                   |
| **TFTP Server 1.4**                  | Directory Traversal     | `exploit/windows/tftp/tftpdwin_directory_traversal` |
| **War-FTP 1.65**                     | USER Command Overflow   | `exploit/windows/ftp/warftpd_165_user`              |
| **Vulnserver (by Stephen Bradshaw)** | Custom vuln service     | Use with custom buffer overflow exploits            |


🛑 Disable antivirus temporarily, as many of these apps are flagged due to their vulnerability.

✅ Run the apps as administrator to allow listening on required ports.

🛡️ Want to Collect Logs with Elastic Agent?
For Windows threat log collection with Elastic, enable these integrations:

**Elastic Integration	Purpose**
Windows	Collects Event Logs, Sysmon logs
System	Collects basic host metrics
Elastic Defend	Behavioral & malware detection
Osquery Manager	Query registry, processes, services
File Integrity	Detects tampering in critical dirs
