#!/bin/bash
set -e
curl -o /tmp/cw.deb https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E /tmp/cw.deb