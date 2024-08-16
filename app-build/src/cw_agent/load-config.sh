#!/bin/bash
set -e
CONFIG_PATH=$1
if [ -z "$CONFIG_PATH" ]; then
    echo "Usage: $0 <config-path>"
    exit 1
fi
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:$CONFIG_PATH