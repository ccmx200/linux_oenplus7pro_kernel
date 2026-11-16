#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== ath10k PS 状态"
cat /sys/kernel/debug/ieee80211/phy0/ath10k/ps_state_enable 2>/dev/null
echo "=== 模块参数"
for f in /sys/module/ath10k_core/parameters/*; do echo "$(basename $f)=$(cat $f 2>/dev/null)"; done 2>/dev/null | head -15
echo "=== mac80211 PS"
iw dev wlan0 get power_save 2>/dev/null
echo "=== 关闭 PS 再测延迟"
echo 0 > /sys/kernel/debug/ieee80211/phy0/ath10k/ps_state_enable 2>/dev/null
iw dev wlan0 set power_save off 2>/dev/null
sleep 2
ping -c 15 -W2 192.168.111.1 2>&1 | tail -3
echo "=== 关闭后吞吐"
curl -4 -s -o /dev/null --max-time 12 -w "speed_MBps=%{speed_download}\n" http://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso
' 2>&1 | grep -v Warning | head -35
