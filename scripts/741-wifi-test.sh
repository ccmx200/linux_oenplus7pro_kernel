#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== MAC 是否已由 DTB 提供"
dmesg -C
modprobe ath10k_snoc 2>&1
sleep 14
echo "--- 关键日志"
dmesg | grep -iE "ath10k|wlan_process|msa|board|mac" | head -25
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
echo "--- 扫描尝试"
iw dev wlan0 scan 2>/dev/null | grep -m5 SSID || nmcli -f SSID dev wifi list 2>/dev/null | head -8
' 2>&1 | grep -v Warning | head -45
