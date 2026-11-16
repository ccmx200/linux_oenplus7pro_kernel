#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 105
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
echo "--- GPU 日志"
dmesg | grep -iE "adreno|gmu|zap|a6xx|gpu" | tail -15
echo "--- DRM 设备"
ls /dev/dri/ 2>/dev/null
ls /sys/class/drm/ | head
echo "--- GPU OPP/频率"
cat /sys/class/drm/card0/device/gt_cur_freq_mhz 2>/dev/null || ls /sys/class/devfreq/ 2>/dev/null | head
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
