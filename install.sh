#!/bin/bash

# Pre-run checks
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run with root permissions."
    exit
fi

# Setup
echo -n "Starting installation, executing setup commands ... "
cd "$(dirname "$0")"
cp -r pihub-client /opt/
cp README.md /opt/pihub-client/README.md
echo finished
echo Beginning verification process.

# Verify device
domain="localhost:8000"
echo -n "Enter your device public key: "; read pubkey
idresp=$(curl -s -w '%{http_code}' -X POST -d public_key=$pubkey http://$domain/api/identify-device)

if [ "$idresp" != "200" ]; then
    echo Error: Could not find device with the provided public key.
    exit 1
fi

echo -n "Enter your device private key: "; read privkey
currtime = $(date +%s)
vhash=$(echo -n "$pubkey$currtime$privkey" | sha256sum)
vdata="public_key=$pubkey&time=$currtime&vhash=$vhash"
vresp=$(curl -w '%{http_code}' -X POST -d $vdata http://$domain/api/verify-device)

if [ "$vresp" != "200" ]; then
    echo Error: Invalid private key.
    exit 2
else
    echo "Success! Your device is now verified."
    "public $pubkey\nprivate $privkey" > /opt/pihub-client/keys.json
fi

# Set up services
echo -n Setting up systemd services...
cp resources/* /etc/systemd/system/
systemctl start pihub.service
systemctl enable pihub.service
systemctl start pihub.timer
systemctl enable pihub.timer
echo "Done!"

