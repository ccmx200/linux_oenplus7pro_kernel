#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 等 180s 看 QMI 结果"
sleep 180
dmesg | grep -iE "ath10k|qmi|wcn|qrtr" | tail -25
echo "=== qrtr"
qrtr-lookup 2>/dev/null | tail -8
echo "=== wlan0"
ip -br link | grep -i wlan || echo none
' 2>&1 | grep -v Warning | head -50
