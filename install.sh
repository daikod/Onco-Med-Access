#!/bin/bash
#
# install.sh: System prerequisite installer for the Oncology Medicines Access Management System
#
# This script checks for and helps install necessary dependencies like Docker and Docker Compose.
# It also creates the required directory structure for the application to run correctly.
#
set -e

echo "--- Oncology Medicines Access Management System Installer ---"
echo "This script will check for prerequisites and set up the necessary directory structure."

# --- Check for Docker ---
if ! command -v docker &> /dev/null; then
    echo "[!] Docker could not be found."
    echo "Please install Docker before proceeding. Visit https://docs.docker.com/engine/install/"
    exit 1
else
    echo "[✔] Docker is installed: $(docker --version)"
fi

# --- Check for Docker Compose ---
if ! command -v docker-compose &> /dev/null; then
    echo "[!] Docker Compose V1 could not be found."
    if docker compose version &> /dev/null; then
        echo "[✔] Docker Compose V2 is installed: $(docker compose version)"
    else
        echo "[!] Docker Compose V2 could not be found either."
        echo "Please install Docker Compose. Visit https://docs.docker.com/compose/install/"
        exit 1
    fi
else
    echo "[✔] Docker Compose V1 is installed: $(docker-compose --version)"
fi

# --- Create required directories ---
echo ""
echo "--- Creating required directories ---"
DIRECTORIES=(
    "nginx/conf.d"
    "ssl"
    "db/init"
    "redis"
    "backups"
    "scripts"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        echo "[✔] Directory '$dir' already exists."
    else
        mkdir -p "$dir"
        echo "[✔] Created directory: $dir"
    fi
done

# --- Set permissions (optional, but good practice) ---
# echo ""
# echo "--- Setting directory permissions ---"
# sudo chown -R $USER:$USER .
# echo "[✔] Permissions updated."

echo ""
echo "--- Installation prerequisites check complete! ---"
echo "Next steps:"
echo "1. Add your SSL certificate (fullchain.pem) and private key (privkey.pem) to the 'ssl/' directory."
echo "2. Create your configuration files (nginx.conf, default.conf, etc.) in the 'nginx/' directory."
echo "3. Run 'configure.sh' to set up your environment and start the application."
