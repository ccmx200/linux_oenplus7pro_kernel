#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 推送官方 board-2.bin（结构正确）"
sshpass -p 1234 scp $OPTS /root/ath10kfw/board-2.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn; sync; reboot' 2>&1 | grep -v Warning
sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- wlan0"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|board|msa" | tail -12
echo "--- scan"
nmcli radio wifi on 2>&1 | head -2
timeout 25 nmcli -f SSID,SIGNAL dev wifi list 2>&1 | head -12
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
