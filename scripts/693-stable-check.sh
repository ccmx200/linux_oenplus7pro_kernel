#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 105
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- uptime"; uptime
echo "--- wlan0（默认应为空，说明未自动加载）"; ip -br link | grep -i wlan || echo none
echo "--- ath10k 模块"; lsmod | grep -c ath10k || true
echo "--- 崩溃计数"; dmesg | grep -c "grace timer" || true
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
