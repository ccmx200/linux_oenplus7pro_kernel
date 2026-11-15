#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 等设备"
for i in $(seq 1 8); do
  sleep 10
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i
done
echo "=== 抓 qmi ids"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask 2>/dev/null
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind
sleep 12
dmesg | grep -iE "qmi|board" | head -20
' 2>&1 | grep -v Warning | head -35
