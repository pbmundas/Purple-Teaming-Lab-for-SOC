### install_vulnerable_ubuntu.sh

This script installs and configures several vulnerable software packages and services commonly used in cybersecurity labs. It includes:

vsftpd 2.3.4 (backdoored FTP server, exploitable via Metasploit's exploit/unix/ftp/vsftpd_234_backdoor module, CVE-2011-2523).
DVWA (Damn Vulnerable Web Application, intentionally vulnerable for web exploits like SQLi, XSS, etc., with Metasploit modules for various web vulns).
Vulnerable rsync and NFS configurations (for remote access and privilege escalation, as per common lab setups; exploitable via Metasploit modules like auxiliary/scanner/rsync/modules_list or NFS-related exploits).
A vulnerable setuid binary (for local privilege escalation, similar to CVE-2023-0386 exploits in Metasploit).

Run this as root (e.g., sudo bash install_vulnerable_ubuntu.sh). It has been derived from tested sources like GitHub repos and lab guides, and assumes a fresh Ubuntu 20.04+ install. Test in a VM for safety.
