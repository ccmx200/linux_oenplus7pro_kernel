#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
DEV=192.168.111.247
sshpass -p 1234 ssh $OPTS root@$DEV '
pkill iperf3 2>/dev/null; sleep 1
nohup iperf3 -s -p 5201 >/tmp/iperf3-s.log 2>&1 &
sleep 1; echo server_ok' 2>&1 | grep -v Warning | tail -1
echo "=== PC → 设备：4 流 + 256K 窗口（设备 RX）"
iperf3 -c $DEV -p 5201 -t 8 -P 4 -w 256K 2>&1 | tail -4
echo "=== 设备 → PC：4 流（设备 TX）"
iperf3 -c $DEV -p 5201 -t 8 -P 4 -R 2>&1 | tail -4
echo "=== 期间速率"
sshpass -p 1234 ssh $OPTS root@$DEV 'iw dev wlan0 link | grep -E "rx bitrate"; iw dev wlan0 station dump | grep -iE "rx drop|tx failed"' 2>&1 | grep -v Warning
