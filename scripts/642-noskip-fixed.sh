#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 部署 no-skip DTB（no-msa 保留），board-2 保持修正版"
sshpass -p 1234 scp $OPTS /root/wq-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- wlan0"; ip -br link | grep -i wlan || echo none
echo "--- ath10k 全流程"; dmesg | grep -iE "ath10k" | tail -20
echo "--- scan"
nmcli radio wifi on 2>&1 | head -2
timeout 25 nmcli -f SSID,SIGNAL dev wifi list 2>&1 | head -12
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
