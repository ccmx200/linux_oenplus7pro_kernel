#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 连接信息"
nmcli -f GENERAL.STATE,GENERAL.CONNECTION,GENERAL.HWADDR device show wlan0 2>/dev/null | head
nmcli -f GENERAL dev show wlan0 2>/dev/null | grep -iE "rate|channel|band|signal" 
echo "=== station dump（若 iw 存在）"
command -v iw >/dev/null && iw dev wlan0 link 2>&1 | head -20 || echo "no iw"
echo "=== debugfs 站点速率"
S=$(ls -d /sys/kernel/debug/ieee80211/phy*/netdev:wlan0/stations/* 2>/dev/null | head -1)
echo "station=$S"
if [ -n "$S" ]; then
  for f in rx_bitrate tx_bitrate signal expected_throughput rx_packets tx_packets connected_time; do
    [ -e "$S/$f" ] && echo "$f = $(cat $S/$f)"
  done
fi
echo "=== /proc/net/wireless"
cat /proc/net/wireless
echo "=== 接口统计"
cat /sys/class/net/wlan0/statistics/rx_bytes /sys/class/net/wlan0/statistics/tx_bytes 2>/dev/null
' 2>&1 | grep -v Warning | head -50
