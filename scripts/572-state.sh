#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== modem 状态"; cat /sys/class/remoteproc/remoteproc0/state
echo "=== qrtr"; qrtr-lookup 2>/dev/null | head -20
echo "=== grace/wlan_process"; dmesg | grep -iE "grace|wlan_process|wlfw" | tail -6
echo "=== ath10k 驱动绑定"; readlink /sys/bus/platform/devices/18800000.wifi/driver
echo "=== pwrseq/gpio50"; grep -E "gpio50|gpio-50" /sys/kernel/debug/gpio | head -2
' 2>&1 | grep -v Warning | head -40
