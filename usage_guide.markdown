# Usage Guide

## Accessing Services
- **n8n**: http://localhost:5678
  - Activate workflows under "Workflows".
- **Kibana**: http://localhost:5601
  - Create index patterns for `zeek_logs` and `suricata_logs`.

## Workflows
1. **Network Scan with Zeek Analysis**
   - Triggers every 5 minutes.
   - Scans Metasploitable with Nmap.
   - Zeek analyzes traffic; results logged in ELK.
2. **Brute Force Attack with Suricata Detection**
   - Triggers every 10 minutes.
   - Simulates SSH brute-force on Metasploitable.
   - Suricata detects alerts; results logged in ELK.

## Managing the Lab
- **Start**: `bash scripts/init.sh`
- **Reset**: `bash scripts/reset.sh`
- **Stop**: `docker-compose down`

## Viewing Results
- In Kibana, use "Discover" to view logs under `zeek_logs` or `suricata_logs`.
- Modify workflows in n8n's editor.