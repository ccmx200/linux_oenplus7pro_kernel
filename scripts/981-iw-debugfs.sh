#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== ieee80211 debugfs"
ls /sys/kernel/debug/ieee80211/ 2>/dev/null
echo "=== phy 目录"
for p in /sys/kernel/debug/ieee80211/phy*; do echo "$p:"; ls "$p" 2>/dev/null | head; done
echo "=== stations"
find /sys/kernel/debug/ieee80211 -maxdepth 4 -name stations 2>/dev/null
S=$(find /sys/kernel/debug/ieee80211 -maxdepth 5 -type d -name "*" -path "*stations*" 2>/dev/null | head -1)
echo "S=$S"
if [ -n "$S" ]; then ls "$S"; for f in rx_bitrate tx_bitrate signal; do echo "$f=$(cat $S/$f 2>/dev/null)"; done; fi
echo "=== nmcli 全量"
nmcli device show wlan0 2>/dev/null | grep -iE "rate|speed|channel|freq|signal|band" 
' 2>&1 | grep -v Warning | head -50
