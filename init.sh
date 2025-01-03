#!/bin/bash

# Set working directory
REPO_DIR="/root/palweed-server"

echo "Changing directory to ${REPO_DIR}"
cd "${REPO_DIR}"

# Ensure the main branch is checked out
echo "Switching to main branch"
git checkout main

# Build and start Docker services
echo "Starting Docker Compose with build..."
docker compose up --build -d

# Wait for the Docker container to initialize
echo "Waiting for Docker container to be ready..."
sleep 10  # Adjust if necessary

# Run initial backup
echo "Running initial backup..."
/usr/bin/python3 "${REPO_DIR}/backup_script.py"

# Check if cron is installed
if ! command -v cron &> /dev/null; then
    echo "Installing cron..."
    apt update
    apt install -y cron
fi

# Ensure cron service is running
echo "Starting cron service..."
service cron start

# Define the cron job to run the backup script every hour
CRON_JOB="0 * * * * /usr"
