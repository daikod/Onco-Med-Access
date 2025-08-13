#!/bin/bash
#
# configure.sh: Environment setup and application starter
#
# This script prepares the .env file, pulls the latest Docker images,
# and starts the application stack using Docker Compose.
#
set -e

echo "--- Oncology Medicines Access Management System Configurator ---"

# --- Check for .env file ---
if [ -f ".env" ]; then
    echo "[✔] .env file found."
else
    echo "[!] .env file not found."
    if [ -f ".env.example" ]; then
        echo "Copying .env.example to .env..."
        cp .env.example .env
        echo "[IMPORTANT] .env file has been created. Please open it and fill in your production values now."
        read -p "Press [Enter] to continue after you have edited the .env file..."
    else
        echo "[ERROR] .env.example not found. Cannot create .env file. Please restore it from your repository."
        exit 1
    fi
fi

echo ""
echo "--- Pulling latest Docker images ---"
# Use 'docker compose' if available, otherwise fall back to 'docker-compose'
if command -v docker-compose &> /dev/null; then
    docker-compose pull
else
    docker compose pull
fi
echo "[✔] Docker images pulled successfully."

echo ""
echo "--- Starting the application stack ---"
echo "This will start all services in detached mode."
if command -v docker-compose &> /dev/null; then
    docker-compose up --build -d
else
    docker compose up --build -d
fi

echo ""
echo "--- Deployment complete! ---"
echo "The application stack is now running."
echo "You can check the status of the containers with 'docker ps'."
echo "To view logs, use 'docker-compose logs -f' or 'docker compose logs -f'."
