#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
for t in 1 2 3; do
  echo "=== 尝试 $t"
  rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 3
  dmesg -C
  modprobe ath10k_snoc
  sleep 15
  dmesg | grep -iE "ath10k|host capability|wlfw" | tail -5
  ip -br link | grep -i wlan && break
done
echo "=== 最终"
ip -br link | grep -i wlan || echo no-wlan
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | grep wlan0
' 2>&1 | grep -v Warning | head -35
