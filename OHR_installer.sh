#!/bin/bash
#
# Pi-Star GitHub Installer
# By WRQC343 - Outlaw Ham Radio
#

set -e

BASE_URL="https://raw.githubusercontent.com/Justice57201/OHR/main"

echo "======================================"
echo " Outlaw Ham Radio Installer Starting"
echo "======================================"

echo "[1/6] Remounting filesystem RW..."
mount -o remount,rw /

TMP_DIR="/tmp/pistar_install"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

echo "[2/6] Downloading files from GitHub..."

curl -fsSL "$BASE_URL/HostFilesUpdate.sh" -o HostFilesUpdate.sh || { echo "Download failed: HostFilesUpdate.sh"; exit 1; }
curl -fsSL "$BASE_URL/lh.txt" -o lh.txt || { echo "Download failed: lh.txt"; exit 1; }
curl -fsSL "$BASE_URL/localtx.txt" -o localtx.txt || { echo "Download failed: localtx.txt"; exit 1; }
curl -fsSL "$BASE_URL/index.php" -o index.php || { echo "Download failed: index.php"; exit 1; }

echo "[3/6] Installing files..."

mv HostFilesUpdate.sh /usr/local/sbin/
chmod 755 /usr/local/sbin/HostFilesUpdate.sh

mv lh.txt /var/www/dashboard/mmdvmhost/lh.php
mv localtx.txt /var/www/dashboard/mmdvmhost/localtx.php
mv index.php /var/www/dashboard/index.php

chmod 644 /var/www/dashboard/mmdvmhost/lh.php
chmod 644 /var/www/dashboard/mmdvmhost/localtx.php
chmod 644 /var/www/dashboard/index.php

rm -f /usr/local/etc/nextionUsers.csv
rm -f /usr/local/etc/nextionGroups.csv

echo "[4/6] Cleaning up..."
cd /
rm -rf "$TMP_DIR"

echo "[5/6] Running HostFilesUpdate.sh..."
if [ -f /usr/local/sbin/HostFilesUpdate.sh ]; then
    /usr/local/sbin/HostFilesUpdate.sh
else
    echo "ERROR: HostFilesUpdate.sh not found!"
    mount -o remount,ro /
    exit 1
fi

echo "[6/6] Restoring filesystem to read-only..."
mount -o remount,ro /

echo "======================================"
echo " Outlaw Ham Radio Install Complete!"
echo "======================================"
