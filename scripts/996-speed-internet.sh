#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
URL="http://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "
echo '=== 下载测速（12s，公网）'
( for i in \$(seq 1 12); do iw dev wlan0 link | grep 'rx bitrate'; sleep 1; done ) &
curl -s -o /dev/null --max-time 12 -w 'speed_Bps=%{speed_download}\n' '$URL' 2>&1 | tail -2
wait
" 2>&1 | grep -v Warning | head -30
