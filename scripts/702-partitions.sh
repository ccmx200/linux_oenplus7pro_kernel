#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== Uptime / WiFi 状态"
uptime; ip -br link | grep -i wlan || echo "no wlan0"
echo "=== boot_a / boot_b 设备"
ls -l /dev/disk/by-partlabel/boot_a /dev/disk/by-partlabel/boot_b /dev/disk/by-partlabel/misc
echo "=== boot_a 前 64 字节"
dd if=/dev/disk/by-partlabel/boot_a bs=1 count=64 2>/dev/null | xxd
echo "=== boot_a 里是否有 U-Boot 字符串"
dd if=/dev/disk/by-partlabel/boot_a bs=1M count=2 2>/dev/null | strings | grep -i -m5 "U-Boot\|uboot"
echo "=== misc 当前内容"
dd if=/dev/disk/by-partlabel/misc bs=1 count=64 2>/dev/null | xxd
' 2>&1 | grep -v Warning | head -40
