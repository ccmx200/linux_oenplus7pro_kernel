#!/bin/bash
set -u
R=/root/fw
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 重新推送固件（解压版）"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'mkdir -p /lib/firmware/ath10k/WCN3990/hw1.0' 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$R"/usr/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin \
    "$R"/usr/lib/firmware/ath10k/WCN3990/hw1.0/firmware-5.bin \
    "$R"/usr/lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn \
    root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning

echo "=== 开 ath10k debug 并重绑"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/
[ -w /sys/module/ath10k_core/parameters/debug_mask ] && echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask && echo "debug_mask set"
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind; echo "bind rc=$?"
sleep 10
dmesg | tail -40
echo "--- qrtr"
ls /sys/bus/../../class/ 2>/dev/null | head -0
ls /dev/qrtr* 2>/dev/null; ls /sys/bus/qrtr/devices 2>/dev/null | head
' 2>&1 | grep -v Warning | head -70
