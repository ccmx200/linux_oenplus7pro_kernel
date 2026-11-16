#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 到网关（路由器）质量"
ping -c 20 -W2 192.168.111.1 2>&1 | tail -3
echo "=== 到 223.5.5.5 质量"
ping -c 10 -W2 223.5.5.5 2>&1 | tail -3
echo "=== 4 并发下载（清华镜像，15s）"
URL=http://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso
for i in 1 2 3 4; do
  curl -4 -s -o /dev/null --max-time 15 -w "conn$i speed_MBps=%{speed_download}\n" "$URL" &
done
wait
echo "=== 期间链路速率"
iw dev wlan0 link 2>/dev/null | grep -E "rx bitrate|signal"
' 2>&1 | grep -v Warning | head -30
