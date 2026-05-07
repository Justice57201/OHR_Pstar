#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0
#
FILE="/etc/mmdvmhost"

if [[ $EUID -ne 0 ]]; then
    echo "Please run with sudo"
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE"
    exit 1
fi

mount -o remount,rw /

if ! grep -q '^Options=UNIT=true$' "$FILE"; then
    sed -i '159i Options=UNIT=true' "$FILE"
    echo "Line added."
else
    echo "Line already exists."
fi
