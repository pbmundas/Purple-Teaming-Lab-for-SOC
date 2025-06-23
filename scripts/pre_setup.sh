#!/bin/bash
echo "Preparing environment for Windows..."
# Convert scripts to Unix line endings
if command -v dos2unix >/dev/null 2>&1; then
    dos2unix init.sh reset.sh
else
    echo "Installing dos2unix..."
    sudo apt-get update && sudo apt-get install -y dos2unix || echo "Please install dos2unix manually or use a text editor to convert line endings."
    dos2unix init.sh reset.sh
fi
# Ensure scripts are executable
chmod +x init.sh reset.sh
echo "Pre-setup complete. Run 'bash init.sh' to start the lab."
