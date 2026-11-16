#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 95
for i in $(seq 1 8); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo down$i; sleep 15
done
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== modem 状态"
cat /sys/class/remoteproc/remoteproc0/state 2>/dev/null
cat /sys/class/remoteproc/remoteproc0/firmware 2>/dev/null
echo "=== 加载 ath10k"
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 1
dmesg -C
modprobe ath10k_snoc
sleep 20
echo "--- 日志"
dmesg | grep -iE "ath10k|wlan_process|msa|modem" | head -25
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
echo "--- 扫描"
nmcli dev wifi rescan 2>/dev/null; sleep 3
nmcli -f SSID,SIGNAL dev wifi list 2>/dev/null | head -10
' 2>&1 | grep -v Warning | head -45
