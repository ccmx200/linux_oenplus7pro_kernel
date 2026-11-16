#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 100
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
echo "--- 显示链路"
dmesg | grep -iE "mdss|dsi|panel|drm|backlight" | tail -20
echo "--- backlight"
ls /sys/class/backlight/ 2>/dev/null
echo "--- fb"
ls /sys/class/graphics/ 2>/dev/null
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo down$i; sleep 15
done
echo DOWN
