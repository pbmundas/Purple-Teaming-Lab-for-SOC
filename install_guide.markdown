# Installation Guide

## Step-by-Step Installation
1. **Install Docker Desktop**
   - Download from [Docker's official website](https://www.docker.com/products/docker-desktop/).
   - Enable WSL 2: Run `wsl --install` in PowerShell as admin.
   - Configure Docker Desktop to use WSL 2 backend.

2. **Install Git**
   - Download from [Git's official website](https://git-scm.com/download/win).
   - Install with default settings.

3. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/purple-teaming-lab.git
   cd purple-teaming-lab
   ```

4. **Set Up Environment**
   - Ensure Docker Desktop is running.
   - Generate a secure key: `openssl rand -base64 32`.
   - Replace `your_secure_key_here` in `docker-compose.yml` and `n8n/.n8n/config.json`.
   - Run the initialization script:
     ```bash
     bash scripts/init.sh
     ```

5. **Verify Setup**
   - n8n: http://localhost:5678 (set up user on first login).
   - Kibana: http://localhost:5601.
   - Check containers: `docker ps`.

## Notes
- Ensure ports 5678, 9200, and 5601 are free.
- The lab is for local use only; do not expose to the internet.