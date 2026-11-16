#!/bin/bash
set -u
# PC 侧：启动 iperf3 服务端（后台）
pkill -f "iperf3 -s" 2>/dev/null
nohup iperf3 -s -p 5201 >/tmp/iperf3-server.log 2>&1 &
sleep 2
ss -ltnp 2>/dev/null | grep 5201 || netstat -ltnp 2>/dev/null | grep 5201
echo "server started"
