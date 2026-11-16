#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 连接状态"
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | grep wlan0
ip -br addr show wlan0 | head -2
echo "=== 到 PC 的连通性"
ping -c2 -W2 192.168.111.125 2>&1 | tail -2
echo "=== 安装 iperf3"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iperf3 2>&1 | tail -3
command -v iperf3 && iperf3 --version | head -1
' 2>&1 | grep -v Warning | head -30
