#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 接口统计"
grep wlan0 /proc/net/dev
echo "=== 站点统计"
iw dev wlan0 station dump 2>/dev/null | grep -iE "rx drop|tx failed|tx retries|beacon loss|signal|bitrate"
echo "=== 内核错误"
dmesg | grep -iE "htt|rx ring|no memory|drop|stall" | tail -8
' 2>&1 | grep -v Warning | head -25
