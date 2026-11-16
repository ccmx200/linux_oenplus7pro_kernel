#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
M=/dev/disk/by-partlabel/misc
echo "=== 备份 misc 前 4KB"
dd if=$M of=/root/misc-backup.bin bs=4096 count=1 2>/dev/null && ls -l /root/misc-backup.bin
echo "=== 原始内容"
xxd -l 64 $M
echo "=== 写入 bootonce-bootloader"
printf "bootonce-bootloader" | dd of=$M bs=1 conv=notrunc 2>/dev/null
sync
echo "=== 写入后"
xxd -l 64 $M
reboot
' 2>&1 | grep -v Warning | head -20
echo "=== 等待并检查 fastboot"
Start-Sleep 70
$pt='C:\Users\cuicanmx\Documents\EEWork\Tools\Android\platform-tools'
cmd /c "`"$pt\fastboot.exe`" devices 2>&1"