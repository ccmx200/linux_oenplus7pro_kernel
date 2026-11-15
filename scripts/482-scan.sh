#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 110
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- wlan0"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|wlfw|qmi" | tail -10
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; break; }
  echo "down $i"; sleep 15
done
echo "=== 尝试扫描"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
nmcli radio wifi on 2>&1 | head -2
sleep 3
timeout 30 nmcli -f SSID,SIGNAL dev wifi list 2>&1 | head -15
echo "--- dmesg tail"
dmesg | grep -iE "ath10k|wlan" | tail -10
' 2>&1 | grep -v Warning | head -40
