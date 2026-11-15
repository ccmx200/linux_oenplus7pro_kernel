#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 90
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
ip -br link | grep -i wlan || echo no-wlan
dmesg | grep -iE "ath10k" | tail -6
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
