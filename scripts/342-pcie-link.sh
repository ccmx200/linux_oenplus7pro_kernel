#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== /sys/bus/pci/devices"
ls /sys/bus/pci/devices
echo "=== 根端口下的子设备"
ls /sys/bus/pci/devices/0000:00:00.0/ | head -20
echo "=== 链路状态（LnkSta）"
cat /sys/bus/pci/devices/0000:00:00.0/link/* 2>/dev/null | head -5
echo "=== lspci 是否存在"
which lspci || (apt-get install -y -qq pciutils >/dev/null 2>&1 && echo installed)
lspci -tv 2>/dev/null | head -10
echo "=== dmesg 里 link up/down"
dmesg | grep -iE "link|ltssm" | tail -8
' 2>&1 | grep -v Warning | head -50
