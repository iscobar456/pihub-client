#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    printf "This script must be run with root permissions."
    exit
fi

printf "Uninstalling:\n"
systemctl -q stop pihub.timer
systemctl -q disable pihub.timer
rm /etc/systemd/system/pihub.timer /etc/systemd/system/pihub.service
systemctl -q daemon-reload
rm -r /opt/pihub-client
printf "done.\n"