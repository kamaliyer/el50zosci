#!/bin/bash

set -e  # Exit immediately if any command exits with a non-zero status

# Print steps for debug
echo "=== Zowe CLI and Z/OS sync ==="

# Check Node.js and install if missing
if ! command -v node &>/dev/null; then
  echo "Node.js not found. Installing..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Install Zowe CLI if not present
if ! command -v zowe &>/dev/null; then
  echo "Zowe CLI not found. Installing..."
  npm install -g @zowe/cli
fi

# Create Zowe profile (overwrite if exists)
zowe profiles delete zosmf github-zos || true

zowe profiles create zosmf github-zos \
  --host "${ZOS_HOST}" \
  --port "${ZOS_PORT}" \
  --user "${ZOS_USER}" \
  --pass "${ZOS_PASS}" \
  --reject-unauthorized false

# Check file exists
if [ ! -f member1 ]; then
  echo "Error: member1 file not found in repo root!"
  exit 1
fi

# Upload file to PDS member
echo "Uploading member1 to ${ZOS_USER}.input(member1) ..."
zowe zos-files upload file-to-data-set "member1" "${ZOS_USER}.input(member1)" --zosmf-profile github-zos --binary false

echo "Upload complete."

# Clean up credentials profile
zowe profiles delete zosmf github-zos

