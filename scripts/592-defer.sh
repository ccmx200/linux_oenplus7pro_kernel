#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== deferred"; head -10 /sys/kernel/debug/devices_deferred 2>/dev/null
echo "=== driver binding"; readlink /sys/bus/platform/devices/18800000.wifi/driver 2>/dev/null || echo unbound
echo "=== wifi dmesg"; dmesg | grep -iE "18800000|ath10k|wifi" | tail -12
echo "=== pwrseq device"; ls /sys/bus/platform/drivers/pwrseq-qcom_wcn/ 2>/dev/null
' 2>&1 | grep -v Warning | head -30
