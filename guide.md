# Purple Teaming Lab Guide

This guide explains how to set up, run, and use the purple teaming lab for SOC operations.

## Prerequisites
- Windows host (I am using) with Virtualbox installed [https://download.virtualbox.org/virtualbox/7.2.2/VirtualBox-7.2.2-170484-Win.exe](Download).
- 32 GB RAM, 256GB SSD (allocate ~16GB RAM (Min) and ~200GB for logs and installations).
- Internet access for pulling Docker images.
- Windows 8.1 ISO for creating Victim machine (To perform platform dependednt attacks) [https://ia802307.us.archive.org/26/items/win-8.1-english_202107/Win8.1_English_x64.iso](Download).
- Ubuntu ISO for creating Victim machine (To perform platform dependednt attacks) - [https://ubuntu.com/download/desktop/thank-you?version=24.04.3&architecture=amd64&lts=true](Download).
- Wazuh pre-installed OVA - ([https://packages.wazuh.com/4.x/vm/wazuh-4.13.1.ova](Download))

I am running **Suricata** and **TheHive** in Docker containers alongside your **Wazuh OVA (Amazon Linux)** makes the lab cleaner, avoids dependency headaches, and keeps things modular.

Here’s the full **step-by-step setup**:

---

# 1. VirtualBox Network Setup

For **Wazuh + Suricata + TheHive VM**:

* **Adapter 1**: **NAT** → for internet updates.
* **Adapter 2**: **Internal Network (`socnet`)** → shared with Kali + Victim VMs.

Enable **Promiscuous Mode = Allow All** on Adapter 2 for Wazuh VM (so Suricata sees all traffic).

Do the same **Internal Network (`socnet`)** for Kali, Ubuntu victim, and Windows victim.

Check Wazuh NICs:

```bash
ip addr
```

* `eth0` = NAT (internet)
* `eth1` = Internal (lab traffic, sniff this with Suricata)

---

# 2. Install Docker on Wazuh VM

```bash
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
```

(Optionally add your user to docker group: `sudo usermod -aG docker $USER`)

---

# 3. Run Suricata in Docker

Create Suricata log dir on host:

```bash
sudo mkdir -p /var/log/suricata
```

Run Suricata container, binding to `eth1`:

```bash
sudo docker run -d --name suricata --net=host -v /var/log/suricata:/var/log/suricata jasonish/suricata:latest -i eth1
```

* `--net=host` → gives container full access to host NICs.
* `-i eth1` → monitor lab network traffic.
* Logs will appear in `/var/log/suricata/eve.json` on the host.

---

# 4. Integrate Suricata Logs with Wazuh

Edit Wazuh config:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Add:

```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/log/suricata/eve.json</location>
</localfile>
```

Restart Wazuh:

```bash
sudo systemctl restart wazuh-manager
```

Now Suricata alerts will show up in the Wazuh dashboard 🎯.

---

# 5. Run TheHive in Docker

TheHive depends on Cassandra + ElasticSearch, but the official Docker image bundles dependencies for simplicity.

Run TheHive:

```bash
sudo docker run -d --name thehive \
  -p 9000:9000 \
  thehiveproject/thehive:latest
```

Access via browser:
`http://<Wazuh-VM-IP>:9000`

Default login:

* **Username**: `admin@thehive.local`
* **Password**: `secret`

(Change immediately)

---

# 6. (Optional) Run Cortex (for enrichment)

```bash
sudo docker run -d --name cortex \
  -p 9001:9001 \
  thehiveproject/cortex:latest
```

Access via browser:
`http://<Wazuh-VM-IP>:9001`

---

# 7. Validate the Pipeline

1. From **Kali**, run a scan on Victim Ubuntu/Windows:

   ```bash
   nmap -sS <victim-ip>
   ```
2. Check Suricata log:

   ```bash
   tail -f /var/log/suricata/eve.json
   ```

   You should see alerts.
3. Check Wazuh dashboard → Suricata alerts ingested.
4. (Optional) Forward incidents to **TheHive** via API or manual case creation.

---

# Final Setup Recap

* **VirtualBox**:

  * Wazuh VM with `eth0=NAT`, `eth1=socnet (promiscuous mode)`
  * Kali + Victims on `socnet`
* **Wazuh**: collects + displays Suricata logs.
* **Suricata (Docker)**: IDS/IPS monitoring `eth1`, logs → `/var/log/suricata/eve.json`.
* **TheHive (Docker)**: Case management on port `9000`.
* **Cortex (Docker, optional)**: Analyzer integrations on port `9001`.

---



## Security Notes
- This lab contains intentionally vulnerable systems. Run it in an isolated environment.
- Do not expose services to the public internet.
- Delete containers and volumes after use to avoid persistent vulnerabilities.
