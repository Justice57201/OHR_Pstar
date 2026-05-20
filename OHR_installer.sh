#!/bin/bash
#
# Pi-Star GitHub Installer
# By Justice - Outlaw Ham Radio
# Version 1.7.0
#

set -e

VERSION="1.7.0"
BASE_URL="https://raw.githubusercontent.com/Justice57201/OHR_Pstar/main"
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

echo "===========================++++=============="
echo " Outlaw Ham Radio Pi-Star Installer v$VERSION"
echo "===============================++++=========="

echo "[1/5] Remounting file system RW..."
mount -o remount,rw /

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || {
    echo "ERROR: Failed to access temp directory"
    exit 1
}

rm -f /usr/local/etc/DCS_Hosts.txt \
      /usr/local/etc/DExtra_Hosts.txt \
      /usr/local/etc/DPlus_Hosts.txt \
      /usr/local/etc/M17Hosts.txt \
      /usr/local/etc/YSFHosts.txt \
      /usr/local/etc/FCSHosts.txt \
      /usr/local/etc/XLXHosts.txt \
      /usr/local/etc/TGList_BM.txt \
      /usr/local/etc/TGList_YSF.txt

echo "[2/5] Downloading files from Github"

curl -fsSL "$BASE_URL/HostFilesUpdate.sh" -o HostFilesUpdate.sh || {
    echo "ERROR: Download failed: HostFilesUpdate.sh"
    exit 1
}

curl -fsSL "$BASE_URL/lh.php" -o lh.php || {
    echo "ERROR: Download failed: lh.php"
    exit 1
}

curl -fsSL "$BASE_URL/localtx.php" -o localtx.php || {
    echo "ERROR: Download failed: localtx.php"
    exit 1
}

curl -fsSL "$BASE_URL/index.php" -o index.php || {
    echo "ERROR: Download failed: index.php"
    exit 1
}

echo "[3/5] Installing files..."

install -m 755 HostFilesUpdate.sh /usr/local/sbin/HostFilesUpdate.sh
install -m 644 lh.php /var/www/dashboard/mmdvmhost/lh.php
install -m 644 localtx.php /var/www/dashboard/mmdvmhost/localtx.php
install -m 644 index.php /var/www/dashboard/index.php

echo "Removing old Nextion files..."

rm -f /usr/local/etc/nextionUsers.csv
rm -f /usr/local/etc/nextionGroups.csv

echo "[4/5] Cleaning up temporary files..."

cd /
rm -rf "$TMP_DIR"

echo "[5/5] Running HostFilesUpdate.sh..."

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
