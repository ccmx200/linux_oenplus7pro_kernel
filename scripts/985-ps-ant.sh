#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 天线/链路"
iw phy phy0 info 2>/dev/null | grep -iE "antenna|chain" | head -10
echo "=== 省电模式（影响速率）"
iw dev wlan0 get power_save 2>/dev/null
nmcli -f 802-11-wireless.powersave connection show cuicanmx_5G 2>/dev/null
echo "=== 当前带宽/信道"
iw dev wlan0 info 2>/dev/null | grep -E "channel|width"
echo "=== 附近 AP 的能力（同信道）"
iw dev wlan0 scan 2>/dev/null | grep -A4 -E "SSID: cuicanmx_5G" | head -12
echo "=== 统计：重传/失败"
iw dev wlan0 station dump 2>/dev/null | grep -iE "retries|failed|bitrate|throughput"
echo "=== ath10k debugfs"
ls /sys/kernel/debug/ieee80211/phy0/ath10k/ 2>/dev/null | head -20
echo "=== 固件/校准日志"
dmesg | grep -iE "ath10k" | tail -8
' 2>&1 | grep -v Warning | head -60
