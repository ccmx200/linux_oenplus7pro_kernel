#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 100
for i in $(seq 1 8); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && break
  echo wait$i; sleep 15
done
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 触摸 probe 日志"
dmesg | grep -iE "s6sy761" | tail -5
ls /dev/input/
echo "=== 安装 evtest"
command -v evtest || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq evtest >/dev/null 2>&1
command -v evtest
' 2>&1 | grep -v Warning | head -15
echo
echo "=== 现在请在屏幕上滑动/点击 12 秒 ==="
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'timeout 12 evtest /dev/input/event1 2>&1 | head -40' 2>&1 | grep -v Warning | head -45
