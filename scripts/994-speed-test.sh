#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 连通性"
timeout 5 curl -s -o /dev/null -w "connect=%{time_connect}\n" http://192.168.111.125:8000/ 2>&1 | tail -1
echo "=== 下载测速（10s）"
( for i in $(seq 1 10); do iw dev wlan0 link | grep "rx bitrate"; sleep 1; done ) &
curl -s -o /dev/null --max-time 10 -w "speed_KBps=%{speed_download}\n" http://192.168.111.125:8000/test300.bin 2>&1 | tail -2
wait
' 2>&1 | grep -v Warning | head -30
