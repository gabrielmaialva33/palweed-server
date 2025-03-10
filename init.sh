#!/bin/bash

# Set working directory
REPO_DIR="/root/palweed-server"

echo "Changing directory to ${REPO_DIR}"
cd "${REPO_DIR}"

# Ensure the main branch is checked out and up-to-date
echo "Switching to main branch"
git checkout main
git pull --rebase

# Build and start Docker services
echo "Starting Docker Compose with build..."
docker compose up --build -d

# Wait for the Docker container to initialize
echo "Waiting for Docker container to be ready..."
sleep 10  # Adjust if necessary

# Run initial backup
echo "Running initial backup..."
/usr/bin/python3 "${REPO_DIR}/backup_script.py"

# Ensure cron service is running
echo "Starting cron service..."
service cron start

# Define the cron job
CRON_JOB="0 * * * * /usr/bin/python3 ${REPO_DIR}/backup_script.py >> /var/log/palweed_backup.log 2>&1"

# Add cron job if it doesn't exist
echo "Configuring cron job..."
(crontab -l 2>/dev/null | grep -q "${CRON_JOB}") || (crontab -l 2>/dev/null; echo "${CRON_JOB}") | crontab -

# Show cron jobs to confirm
echo "Current cron jobs:"
crontab -l

echo "Initialization complete!"
