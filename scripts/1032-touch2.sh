#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 模块文件"
find /lib/modules/$(uname -r) -name "s6sy761.ko*" 2>/dev/null
echo "=== modprobe 详细"
modprobe -v s6sy761 2>&1 | head -5
echo "rc=$?"
dmesg | tail -20
echo "=== i2c 适配器"
ls /sys/bus/i2c/devices/ 2>/dev/null | head -20
echo "=== 触摸节点"
find /proc/device-tree -maxdepth 5 -name "s6sy761*" -o -maxdepth 5 -name "touchscreen@48" 2>/dev/null | head
' 2>&1 | grep -v Warning | head -45
