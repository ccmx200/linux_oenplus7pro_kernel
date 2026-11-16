#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 4 并发（清华）"
U=http://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso
for i in 1 2 3 4; do curl -4 -s -o /dev/null --max-time 12 -w "c$i=%{speed_download}\n" "$U" & done
wait
echo "=== 4 并发（中科大）"
U2=https://mirrors.ustc.edu.cn/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso
for i in 1 2 3 4; do curl -4 -s -o /dev/null --max-time 12 -w "u$i=%{speed_download}\n" "$U2" & done
wait
echo "=== 期间速率"
iw dev wlan0 link 2>/dev/null | grep -E "rx bitrate|signal"
' 2>&1 | grep -v Warning | head -30
