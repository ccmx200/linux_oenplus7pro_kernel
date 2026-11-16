#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
DEV=192.168.111.247
echo "=== 启动设备端 iperf3 服务 + 速率采样"
sshpass -p 1234 ssh $OPTS root@$DEV '
pkill iperf3 2>/dev/null; sleep 1
nohup iperf3 -s -p 5201 >/tmp/iperf3-s.log 2>&1 &
sleep 1
( for i in $(seq 1 40); do iw dev wlan0 link 2>/dev/null | grep "rx bitrate"; sleep 0.5; done > /tmp/rate.log 2>&1 ) &
echo server_ok
ss -ltn 2>/dev/null | grep 5201 || netstat -ltn 2>/dev/null | grep 5201
' 2>&1 | grep -v Warning | head -5
echo
echo "=== PC → 设备（设备 RX 方向）"
iperf3 -c $DEV -p 5201 -t 8 2>&1 | tail -5
echo
echo "=== 设备 → PC（设备 TX 方向，-R）"
iperf3 -c $DEV -p 5201 -t 8 -R 2>&1 | tail -5
echo
echo "=== 期间链路速率统计"
sshpass -p 1234 ssh $OPTS root@$DEV 'sort /tmp/rate.log | uniq -c | sort -rn | head -8' 2>&1 | grep -v Warning
