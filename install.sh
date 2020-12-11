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
chmod u+x /opt/pihub-client/scripts/update_pihub.sh
echo finished
echo Beginning verification process.

# Verify device
domain="localhost:8000"
echo -n "Enter your device public key: "; read pubkey
idresp=$(curl -s -o /dev/null -w '%{http_code}' -X POST -d public_key=$pubkey http://$domain/api/identify-device)

if [ "$idresp" != "200" ]; then
    echo Error: Could not find device with the provided public key.
    exit 1
fi

echo -n "Enter your device private key: "; read -s privkey
currtime=$(date +%s)
vhash=$(echo -n "$pubkey$currtime$privkey" | sha256sum | sed 's/\s.*//')
vdata="public_key=$pubkey&time=$currtime&vhash=$vhash"
vresp=$(curl -s -o /dev/null -w '%{http_code}' -X POST -d "$vdata" http://$domain/api/verify-device)

if [ "$vresp" != "200" ]; then
    echo \nError: Invalid private key.
    exit 2
else
    echo ""
    echo "Success! Your device is now verified."
    echo public $pubkey > /opt/pihub-client/keys.conf
    echo private $privkey >> /opt/pihub-client/keys.conf
fi

# Set up services
echo -n "Setting up systemd services ... "
cp resources/* /etc/systemd/system/
systemctl daemon-reload
systemctl start pihub.timer
systemctl enable pihub.timer
echo "Done!"
exit 0

