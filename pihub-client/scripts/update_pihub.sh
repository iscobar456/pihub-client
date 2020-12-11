#!/bin/bash

cd /opt/pihub-client/

pubkey=$(grep public keys.conf | awk '{print $2}')
privkey=$(grep private keys.conf| awk '{print $2}')
currtime=$(date +%s)
vhash=$(echo -n "$pubkey$currtime$privkey" | sha256sum | sed 's/\s.*//')

req_data="\
public_key=$pubkey&\
time=$currtime&\
vhash=$vhash"

response=$(curl -s -o /dev/null -w '%{http_code}' -X POST -d $req_data http://localhost:8000/api/device-update)

if [ "$response" = "200" ]; then
    echo Successfully sent update.
    exit 0
fi
