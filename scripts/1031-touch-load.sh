#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== i2c17 是否启用（DTB）"
ls /proc/device-tree/soc@0/i2c@* 2>/dev/null | head -20
for d in /proc/device-tree/soc@0/i2c@*; do
  n=$(cat "$d/reg" 2>/dev/null | xxd -p 2>/dev/null)
  s=$(tr -d "\0" < "$d/status" 2>/dev/null)
  echo "$(basename $d) status=$s"
done 2>/dev/null | head -20
echo "=== 模块"
lsmod | grep s6sy761 || echo "not loaded"
modprobe s6sy761 2>&1
sleep 3
echo "=== dmesg"
dmesg | grep -iE "s6sy761|i2c.*geni|touch" | tail -15
echo "=== 输入设备"
ls /dev/input/ 2>/dev/null
cat /proc/bus/input/devices 2>/dev/null | grep -A4 -i "s6sy761\|touch" | head -15
' 2>&1 | grep -v Warning | head -50
