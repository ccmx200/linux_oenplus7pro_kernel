#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 部署 guac 原厂 BDF 的 board-2"
sshpass -p 1234 scp $OPTS /root/board-2-guac-real.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
rm -f $A/board.bin
ls -lh $A/board-2.bin
echo "=== 重新加载 ath10k"
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null; sleep 1
dmesg -C
modprobe ath10k_snoc
sleep 12
dmesg | grep -iE "ath10k.*(board|cal|fw_version|chip_id)" | head -8
echo "=== 等待重连"
sleep 8
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | head -3
iw dev wlan0 link 2>/dev/null | head -8
' 2>&1 | grep -v Warning | head -40
