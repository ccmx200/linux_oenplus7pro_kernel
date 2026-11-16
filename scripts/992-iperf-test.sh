#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 安装 iperf3"
command -v iperf3 || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iperf3 2>&1 | tail -3
command -v iperf3 && iperf3 --version | head -1
' 2>&1 | grep -v Warning | head -15
echo "=== 客户端测试（TCP 上行/下行）"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
( sleep 3; for i in 1 2 3 4 5 6; do iw dev wlan0 link | grep -E "rx bitrate"; sleep 1; done ) &
iperf3 -c 192.168.111.125 -p 5201 -t 6 -P 1 2>&1 | tail -6
echo "--- 反向（下行）"
iperf3 -c 192.168.111.125 -p 5201 -t 6 -P 1 -R 2>&1 | tail -6
' 2>&1 | grep -v Warning | head -40
