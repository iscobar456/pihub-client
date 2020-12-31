#!/bin/bash

######################
# Constant variables #
######################
domain="localhost:8000"


#############
# Functions #
#############
setup() {
    printf "Starting installation, executing setup commands ... "
    cd "$(dirname "$0")"
    cp -r pihub-client /opt/
    cp README.md /opt/pihub-client/README.md
    chmod u+x /opt/pihub-client/scripts/update_pihub.sh
    printf "finished\n\nNow beginning verification process.\n"
    verify_device
}

verify_device() {
    printf "Enter your device public key: "; read pubkey
    idresp=$(curl -s -o /dev/null -w '%{http_code}' -X POST -d public_key=$pubkey http://$domain/api/identify-device)

    if [ "$idresp" != "200" ]; then
        printf "Error: Could not find device with the provided public key.\n"
        exit 0
    fi

    printf "Enter your device private key: "; read -s privkey
    currtime=$(date +%s)
    vhash=$(printf "$pubkey$currtime$privkey" | sha256sum | sed 's/\s.*//')
    vdata="public_key=$pubkey&time=$currtime&vhash=$vhash"
    vresp=$(curl -s -o /dev/null -w '%{http_code}' -X POST -d "$vdata" http://$domain/api/verify-device)

    if [ "$vresp" != "200" ]; then
        printf "\nError: Invalid private key.\n"
        exit 0
    else
        printf "\nSuccess! Your device is now verified.\n\n"
        printf public $pubkey > /opt/pihub-client/keys.conf
        printf private $privkey >> /opt/pihub-client/keys.conf
    fi
    start_services
}

start_services() {
    printf "Setting up systemd services:\n"
    cp resources/* /etc/systemd/system/
    systemctl -q daemon-reload
    systemctl -q start pihub.timer
    systemctl -q enable pihub.timer
    printf "done.\n"
    exit 0
}


################
# Script entry #
################
if [ $(id -u) -ne 0 ]; then
    printf "This script must be run with root permissions."
    exit
fi

if [ -d "/opt/pihub-client" ]; then
    printf "Removing existing installation:\n"
    systemctl -q stop pihub.timer
    systemctl -q disable pihub.timer
    rm /etc/systemd/system/pihub.timer /etc/systemd/system/pihub.service
    systemctl -q daemon-reload
    rm -r /opt/pihub-client
    printf "done.\n\n"
    setup
fi