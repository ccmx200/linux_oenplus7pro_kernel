#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo 0xffffffff > /sys/module/ath10k_core/debug_mask 2>/dev/null
echo 7 > /proc/sys/kernel/printk 2>/dev/null
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind
sleep 15
echo "=== board name 行"
dmesg | grep -iE "board name|board-2|bd_ie|fetch board" | head -10
echo "=== 其它关键"
dmesg | grep -iE "qmi|msa" | head -10
' 2>&1 | grep -v Warning | head -35
