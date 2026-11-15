#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== deferred 列表（原始）"
head -30 /sys/kernel/debug/devices_deferred 2>/dev/null
echo "=== regulator 摘要（关注的几路）"
grep -E "l1a|l7a|l2c|l11c" /sys/kernel/debug/regulator/regulator_summary 2>/dev/null | head -12
echo "=== 重新 bind 后再看"
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C; echo 18800000.wifi > $D/bind
sleep 5
grep -E "l1a|l7a|l2c|l11c" /sys/kernel/debug/regulator/regulator_summary 2>/dev/null | head -12
dmesg | tail -15
' 2>&1 | grep -v Warning | head -70
