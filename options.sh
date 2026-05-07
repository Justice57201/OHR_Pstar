#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0 - 
#

FILE="/etc/mmdvmhost"
rpi-rw

if ! grep -q '^Options=UNIT=true$' "$FILE"; then
    sudo sed -i '159i Options=UNIT=true' "$FILE"
    echo "Line added."
else
    echo "Line already exists."
fi

rpi-ro
