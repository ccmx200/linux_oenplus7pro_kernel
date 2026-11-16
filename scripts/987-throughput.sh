#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 下载吞吐（阿里云镜像，限时 12s）"
curl -s -o /dev/null --max-time 12 -w "speed=%{speed_download} B/s  size=%{size_download}\n" \
  http://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.3-live-server-amd64.iso 2>&1 | tail -2
echo "=== 期间链路速率"
iw dev wlan0 link 2>/dev/null | grep -E "rx bitrate|signal"
echo "=== 各链信号"
iw dev wlan0 station dump 2>/dev/null | grep -iE "signal|chains|bitrate"
' 2>&1 | grep -v Warning | head -25
