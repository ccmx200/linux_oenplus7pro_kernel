#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
sleep 45
echo "=== dmesg ath10k"
dmesg | grep -iE "ath10k|qmi|wcn|firmware" | tail -30
echo "=== ieee80211"; ls /sys/class/ieee80211 2>/dev/null; ip -br link | grep -i wlan
echo "=== qrtr"; ls /sys/bus/qrtr/devices 2>/dev/null | head; which qrtr-lookup 2>/dev/null
' 2>&1 | grep -v Warning | head -45
