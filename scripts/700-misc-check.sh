#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 块设备"
lsblk -o NAME,SIZE,PARTLABEL 2>/dev/null | head -20
echo "=== by-partlabel"
ls /dev/disk/by-partlabel 2>/dev/null | head -20
echo "=== misc 是否存在"
ls -l /dev/disk/by-partlabel/misc 2>/dev/null || echo "MISC_NOT_FOUND"
' 2>&1 | grep -v Warning | head -50
