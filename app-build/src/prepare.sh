#!/bin/bash
set -e

# Copy aws config
mkdir -p ~/.aws
cp aws_config ~/.aws/config

# Install cw
./cw_agent/download-ubuntu.sh
./cw_agent/load-config.sh

# Load systemctl service
cp ws.service /etc/systemd/system/

# Copy app
mkdir -p /app/log
cp -r app/* /app/