#!/bin/bash
#
# Pi-Star GitHub Installer
# By WRQC343 - Outlaw Ham Radio
# Version 1.7.0
#

set -e

VERSION="1.7.0"
BASE_URL="https://raw.githubusercontent.com/Justice57201/OHR/main"
TMP_DIR="/tmp/pistar_install"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

command -v curl >/dev/null 2>&1 || {
    echo "ERROR: curl is required but not installed."
    exit 1
}

cleanup() {
    echo ""
    echo "Restoring filesystem to read-only..."
    mount -o remount,ro / || true
}
trap cleanup EXIT

echo "======================================"
echo " Outlaw Ham Radio Installer v$VERSION"
echo "======================================"

echo "[1/6] Remounting file system RW..."
mount -o remount,rw /

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || {
    echo "ERROR: Failed to access temp directory"
    exit 1
}

echo "[2/6] Downloading files from Github"

curl -fsSL "$BASE_URL/HostFilesUpdate.sh" -o HostFilesUpdate.sh || {
    echo "ERROR: Download failed: HostFilesUpdate.sh"
    exit 1
}

curl -fsSL "$BASE_URL/lh.txt" -o lh.txt || {
    echo "ERROR: Download failed: lh.txt"
    exit 1
}

curl -fsSL "$BASE_URL/localtx.txt" -o localtx.txt || {
    echo "ERROR: Download failed: localtx.txt"
    exit 1
}

curl -fsSL "$BASE_URL/index.php" -o index.php || {
    echo "ERROR: Download failed: index.php"
    exit 1
}

echo "[3/6] Preparing directories..."

mkdir -p /usr/local/sbin
mkdir -p /var/www/dashboard/mmdvmhost

echo "[4/6] Installing files..."

install -m 755 HostFilesUpdate.sh /usr/local/sbin/HostFilesUpdate.sh
install -m 644 lh.txt /var/www/dashboard/mmdvmhost/lh.php
install -m 644 localtx.txt /var/www/dashboard/mmdvmhost/localtx.php
install -m 644 index.php /var/www/dashboard/index.php

echo "Removing old Nextion files..."

rm -f /usr/local/etc/nextionUsers.csv
rm -f /usr/local/etc/nextionGroups.csv

echo "[5/6] Cleaning up temporary files..."

cd /
rm -rf "$TMP_DIR"

echo "[6/6] Running HostFilesUpdate.sh..."

if [ -x /usr/local/sbin/HostFilesUpdate.sh ]; then
    /usr/local/sbin/HostFilesUpdate.sh
else
    echo "ERROR: HostFilesUpdate.sh not found or not executable!"
    exit 1
fi

echo "======================================"
echo " Outlaw Ham Radio Install Complete!"
echo "======================================"
exit 0
