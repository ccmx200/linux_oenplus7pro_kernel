#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/touch-final.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo s6sy761 > /etc/modules-load.d/touch.conf
sync; reboot' 2>&1 | grep -v Warning
echo "=== 等待启动"
sleep 110
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
echo "--- i2c 适配器"
ls /sys/bus/i2c/devices/ 2>/dev/null | head -10
echo "--- 触摸"
lsmod | grep s6sy761 || echo "s6sy761 not loaded"
dmesg | grep -iE "s6sy761|i2c.*geni|geniqup" | tail -10
echo "--- 输入设备"
cat /proc/bus/input/devices 2>/dev/null | grep -B2 -A4 -i "s6sy761" | head -12
ls /dev/input/
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
