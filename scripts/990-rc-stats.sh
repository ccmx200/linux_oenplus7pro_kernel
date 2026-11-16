#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== ieee80211 树"
find /sys/kernel/debug/ieee80211 -maxdepth 4 -type d 2>/dev/null | head -15
echo "=== minstrel 速率统计"
for f in $(find /sys/kernel/debug/ieee80211 -name rc_stats 2>/dev/null); do echo "--- $f"; head -25 "$f"; done
echo "=== survey（信道占用）"
iw dev wlan0 survey dump 2>/dev/null | grep -A6 "in use" | head -20
echo "=== tpc stats"
head -30 /sys/kernel/debug/ieee80211/phy0/ath10k/tpc_stats 2>/dev/null
echo "=== 站点速率/期望吞吐"
iw dev wlan0 station dump 2>/dev/null | grep -iE "bitrate|throughput|signal|tx failed|tx retries"
' 2>&1 | grep -v Warning | head -80
