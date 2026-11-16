#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== drm 设备"
ls /sys/class/drm 2>/dev/null | head
echo "=== deferred"
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
head -20 /sys/kernel/debug/devices_deferred 2>/dev/null
echo "=== msm/mdss dmesg"
dmesg | grep -iE "msm|mdss|dpu|dispcc|gdsc" | tail -20
echo "=== panel/csipro"
dmesg | grep -iE "panel|dsi" | tail -15
echo "=== 恢复 loader 默认"
cat /boot/loader/loader.conf
' 2>&1 | grep -v Warning | head -60
