#!/bin/bash

# Exit if any command fails
set -e

echo "🔍 Checking for Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "⛔ Docker not found. Please install Docker Desktop and enable WSL2 integration."
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "⛔ Docker Compose plugin not found. Ensure Docker Desktop is installed and updated."
    exit 1
fi

echo "✅ Docker and Docker Compose found."

# Directory where the lab will be cloned
INSTALL_DIR="$HOME/blue-team-lab"

echo "📁 Creating lab directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Skip cloning if repo already exists
if [ -d ".git" ]; then
    echo "📁 Git repo already exists. Skipping clone."
else
    echo "📦 Cloning lab..."
    git clone https://github.com/pbmundas/Purple-Teaming-Lab-for-SOC.git .
fi

echo "📦 Pulling Docker images..."
docker compose pull

echo "🚀 Starting lab environment..."
docker compose up -d

echo ""
echo "✅ Lab is running!"
echo "Access Caldera at:   http://localhost:8888"
echo "Access Kibana at:    http://localhost:5601"
echo ""
