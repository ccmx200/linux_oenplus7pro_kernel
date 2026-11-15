#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 绑定状态"
readlink /sys/bus/platform/devices/18800000.wifi/driver 2>/dev/null || echo "无 driver"
echo "=== ath 模块"
lsmod | grep -E "ath|pwrseq" 
echo "=== 全部 ath 日志"
dmesg | grep -i "ath" | tail -15
echo "=== 手动 unbind/bind 并立刻看日志"
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null
sleep 1
echo 18800000.wifi > $D/bind; echo "bind=$?"
sleep 5
dmesg | tail -15
' 2>&1 | grep -v Warning | head -50
