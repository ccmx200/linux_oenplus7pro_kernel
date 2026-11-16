#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== apt 镜像"
grep -rhoE "https?://[^ ]+" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | sort -u | head -5
echo "=== IPv4 连通性/下载测试"
M=$(grep -rhoE "https?://[^ ]+" /etc/apt/sources.list.d/* 2>/dev/null | head -1)
echo "mirror=$M"
for u in "http://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso" "http://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04/ubuntu-24.04.5-live-server-amd64.iso"; do
  echo "--- $u"
  curl -4 -s -o /dev/null --max-time 15 -w "code=%{http_code} speed_MBps=%{speed_download}\n" "$u" 2>&1 | tail -1
done
' 2>&1 | grep -v Warning | head -20
