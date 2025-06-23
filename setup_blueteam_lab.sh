#!/bin/bash

# Exit if any command fails
set -e

echo "🔍 Checking for Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "⛔ Docker not found. Please install Docker Desktop and enable WSL2 integration."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🔄 Installing docker-compose..."
    sudo apt update
    sudo apt install -y docker-compose
fi

echo "✅ Docker and Docker Compose found."

# Directory where the lab will be cloned
INSTALL_DIR="$HOME/blue-team-lab"

echo "📁 Creating lab directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Use your actual lab GitHub repo if available
echo "📦 Cloning lab..."
git clone https://github.com/pbmundas/Purple-Teaming-Lab-for-SOC.git .  # Replace with your repo if custom

echo "📦 Pulling Docker images..."
docker-compose pull

echo "🚀 Starting lab environment..."
docker-compose up -d

echo ""
echo "✅ Lab is running!"
echo "Access Caldera at:   http://localhost:8888"
echo "Access Kibana at:    http://localhost:5601"
echo ""
