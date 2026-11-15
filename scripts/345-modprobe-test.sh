#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask 2>/dev/null
modprobe -r ath10k_snoc 2>&1 | head -2
sleep 2
dmesg -C
modprobe ath10k_snoc 2>&1 | head -3
echo modprobe=$?
sleep 70
echo "=== dmesg"
dmesg | grep -iE "ath10k|qmi|qrtr|wcn" | tail -30
echo "=== qrtr"; qrtr-lookup 2>/dev/null | tail -6
echo "=== ieee"; ls /sys/class/ieee80211 2>/dev/null
' 2>&1 | grep -v Warning | head -60
