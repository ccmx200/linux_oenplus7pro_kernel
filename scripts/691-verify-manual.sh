#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- 默认状态下 wlan0（应为空）"; ip -br link | grep -i wlan || echo none
echo "--- 手动启动 wifi"
/usr/local/sbin/wifi-on.sh 2>&1 | tail -5
sleep 5
echo "--- dmesg"
dmesg | grep -iE "ath10k" | tail -10
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
