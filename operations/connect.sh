#!/bin/bash
set -e

IP=$1
if [ -z "$IP" ]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

ssh -i ./id_rsa ubuntu@$IP