#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=5"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
cat > /boot/loader/entries/panel.conf <<EOF
title Ubuntu (panel test)
linux /vmlinuz
initrd /initrd.img
devicetree /dtbs/qcom/guac-panel.dtb
options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0
EOF
ls -l /boot/loader/entries/
echo "=== bootctl 版本"
bootctl --version 2>&1 | head -2
echo "=== set-oneshot"
bootctl set-oneshot panel.conf 2>&1 | head -5
bootctl set-oneshot panel 2>&1 | head -5
echo "=== 重启"
sync; reboot' 2>&1 | grep -v Warning | head -25
echo "=== 等待 / 轮询"
sleep 60
for i in $(seq 1 10); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
tr -d "\0" < /proc/device-tree/soc@0/dsi@ae94000/status 2>/dev/null || echo no-dsi
ls /proc/device-tree/soc@0/dsi@ae94000/panel@0 2>/dev/null && echo PANEL_OK
dmesg | grep -iE "mdss|dsi|panel|drm" | tail -12' 2>/dev/null)
  if [ -n "$out" ]; then echo "boot $i:"; echo "$out"; exit 0; fi
  echo "boot $i: no ssh"; sleep 12
done
echo "HANG (面板 DTB 启动挂起)"
