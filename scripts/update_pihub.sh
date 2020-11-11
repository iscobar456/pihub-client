#!/bin/bash

cd /opt/pihub/

ID = $(cat device_id)
HOSTNAME = $(cat /etc/hostname)

req_data = "\
id=$ID&\
"

response = $(curl -X POST -F $req_data http://pihub.site/api/device-update)

if [ -n '$response' ]; then
    device_id < '$response'
fi
