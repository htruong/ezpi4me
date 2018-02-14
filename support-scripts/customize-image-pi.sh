#!/bin/bash

# ezpi4me

# Raspberry Pi ME Cleaner image customization script
# Written by Huan Truong <htruong@tnhh.net>, 2018
# This script is licensed under GNU Public License v3

###############################################################################

print_banner() {
    echo "---- WELCOME TO THE RASPBERRY PI IMAGE CUSTOMIZER --------------"
    sleep 1
    echo " Congratulations, we have gone a long way."
    sleep 1
    echo " I will prepare some software for you, sit tight."
    sleep 1
    echo ""
    echo ""
    echo ""
}

change_bootconfig() {
    sed -i 's/ quiet init\=.*$/ modules-load=dwc2,g_serial/' /boot/cmdline.txt
    echo "dtoverlay=dwc2" >> /boot/config.txt
    echo "dtparam=spi=on" >> /boot/config.txt
    systemctl enable getty@ttyGS0.service
}

get_deps() {
    apt update
    #apt upgrade
    apt -y install git flashrom
}

mark_script_run() {
    touch /etc/customizer_done
}

get_mecleaner() {
    git clone https://github.com/corna/me_cleaner
    cp me_cleaner/me_cleaner.py /usr/local/bin
}


###############################################################################

if [ -f /etc/customizer_done ]; then
    echo "This script has been run before. Nothing to do."
    exit 0
fi

cd 

print_banner

change_bootconfig

get_deps

get_mecleaner

mark_script_run
