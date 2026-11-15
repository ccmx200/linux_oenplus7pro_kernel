#!/bin/bash
set -u
cd /root
rm -rf /root/fwdebs && mkdir -p /root/fwdebs
cd /root/fwdebs
export DEBIAN_FRONTEND=noninteractive
apt-get download firmware-atheros 2>&1 | tail -2
ls -lh *.deb 2>/dev/null
D=$(ls *.deb | head -1)
[ -n "$D" ] && dpkg-deb -x "$D" ./x && find ./x -path '*WCN3990*' -o -name 'wlanmdsp*' | head -10
