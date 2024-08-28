#!/bin/bash
set -e

# Get script dir
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

IP=$1
if [ -z "$IP" ]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

ssh -i $SCRIPT_DIR/../id_rsa ubuntu@$IP