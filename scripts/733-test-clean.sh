#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 105
for i in $(seq 1 6); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo down$i; sleep 15
done
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 默认 wlan0（应为空）"; ip -br link | grep -i wlan || echo none
dmesg -C
modprobe ath10k_snoc 2>&1
sleep 12
echo "=== 完整流程"
dmesg | grep -iE "ath10k" | head -30
echo "=== wlan0"
ip -br link | grep -i wlan || echo none
' 2>&1 | grep -v Warning | head -45
