#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== kexec 加载（面板 DTB）"
kexec -l /boot/vmlinuz --initrd=/boot/initrd.img --dtb=/boot/dtbs/qcom/guac-panel.dtb --reuse-cmdline 2>&1 | tail -5
echo "loaded=$(cat /sys/kernel/kexec_loaded 2>/dev/null)"
if [ "$(cat /sys/kernel/kexec_loaded 2>/dev/null)" = "1" ]; then
  echo "=== 执行 kexec"
  sync
  kexec -e
fi
' 2>&1 | grep -v Warning | head -20
echo "=== kexec 已触发，等待 100s 观察"
sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
echo "--- 显示"
dmesg | grep -iE "mdss|dsi|panel|drm|backlight" | tail -20
ls /sys/class/backlight 2>/dev/null
ls /sys/class/graphics 2>/dev/null
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "wait$i"
  sleep 15
done
echo "NO_SSH_可能已挂起或重启中"
