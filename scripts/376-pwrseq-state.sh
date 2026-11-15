#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== pwrseq 绑定"
ls -l /sys/bus/platform/drivers/pwrseq-qcom_wcn/ 2>/dev/null | head -5
echo "=== pwrseq dmesg"
dmesg | grep -iE "pwrseq|wcn3998|swctrl" | tail -15
echo "=== ath10k 绑定/defer"
readlink /sys/bus/platform/devices/18800000.wifi/driver 2>/dev/null || echo unbound
cat /sys/kernel/debug/devices_deferred 2>/dev/null | head -5
echo "=== 开 debug 重绑"
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1; dmesg -C; echo 18800000.wifi > $D/bind
sleep 8
dmesg | tail -20
' 2>&1 | grep -v Warning | head -60
