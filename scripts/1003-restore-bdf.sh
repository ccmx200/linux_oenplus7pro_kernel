#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/hotdog-fw/board-2.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
ls -lh $A/board-2.bin
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 2
dmesg -C
modprobe ath10k_snoc
sleep 15
echo "--- 连接状态"
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | grep wlan0
iw dev wlan0 link 2>/dev/null | grep -E "SSID|rx bitrate|signal"
echo "--- 日志"
dmesg | grep -iE "ath10k" | tail -6
' 2>&1 | grep -v Warning | head -30
