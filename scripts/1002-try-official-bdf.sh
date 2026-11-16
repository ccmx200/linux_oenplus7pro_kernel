#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 1) 恢复 hotdog board-2"
sshpass -p 1234 scp $OPTS /root/hotdog-fw/board-2.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 1
modprobe ath10k_snoc
sleep 14
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | grep wlan0
iw dev wlan0 link 2>/dev/null | grep -E "SSID|rx bitrate|signal"
' 2>&1 | grep -v Warning | head -15
echo
echo "=== 2) 试官方 linux-firmware board-2"
sshpass -p 1234 scp $OPTS /root/ath10kfw/board-2.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 1
dmesg -C
modprobe ath10k_snoc
sleep 14
echo "--- 日志"
dmesg | grep -iE "ath10k.*(board|cal|vdev|fw_version)" | head -8
echo "--- 连接"
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | grep wlan0
iw dev wlan0 link 2>/dev/null | grep -E "SSID|rx bitrate|signal"
' 2>&1 | grep -v Warning | head -25
