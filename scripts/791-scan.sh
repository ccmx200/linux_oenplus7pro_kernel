#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 接口"
ip -br link | grep -i wlan
echo "=== rfkill"
rfkill list wlan 2>/dev/null | head -6
echo "=== 扫描（nmcli）"
nmcli radio wifi on 2>&1 | head -2
nmcli dev wifi rescan 2>&1 | head -3
sleep 6
nmcli -f SSID,SIGNAL,SECURITY dev wifi list 2>&1 | head -15
echo "=== dmesg 尾部"
dmesg | grep -iE "ath10k|wlan" | tail -8
' 2>&1 | grep -v Warning | head -45
