#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== loader entries"
ls /boot/loader/entries/ 2>/dev/null
for f in /boot/loader/entries/*.conf; do echo "--- $f"; cat "$f"; done 2>/dev/null
echo "=== loader.conf"
cat /boot/loader/loader.conf 2>/dev/null
echo "=== wifi 状态"
ip -br link | grep -i wlan || echo none
lsmod | grep ath10k | head -3
' 2>&1 | grep -v Warning | head -50
