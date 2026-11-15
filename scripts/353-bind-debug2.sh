#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 设备状态"
cat /sys/bus/platform/devices/18800000.wifi/driver 2>/dev/null || readlink /sys/bus/platform/devices/18800000.wifi/driver || echo "未绑定"
echo "=== deferred"
cat /sys/kernel/debug/devices_deferred 2>/dev/null | head
echo "=== 手动绑定（先开 debug）"
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask
D=/sys/bus/platform/drivers/ath10k_snoc
dmesg -C
echo 18800000.wifi > $D/bind; echo "bind=$?"
sleep 30
dmesg | tail -40
echo "=== wlan"; ip -br link | grep -i wlan || echo none
echo "=== qrtr"; qrtr-lookup 2>/dev/null | tail -8
' 2>&1 | grep -v Warning | head -70
