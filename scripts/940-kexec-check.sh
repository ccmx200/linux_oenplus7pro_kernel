#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== kexec 工具"
command -v kexec || echo "no kexec"
ls -l /sbin/kexec /usr/sbin/kexec 2>/dev/null
echo "=== 内核 kexec 支持"
ls /sys/kernel/ | grep -i kexec || echo "no kexec sysfs"
echo "=== cmdline"
cat /proc/cmdline
echo "=== boot 目录"
ls -lh /boot
' 2>&1 | grep -v Warning | head -30
