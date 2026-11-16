#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
K=/root/kbuild/linux
KV=7.3.0-sm8150-g8611da353242-dirty
DEST=/lib/modules/$KV/kernel/drivers/gpu/drm/panel
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.ko" root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
DEST=/lib/modules/7.3.0-sm8150-g8611da353242-dirty/kernel/drivers/gpu/drm/panel
ls -lh $DEST/panel-samsung-oneplus-dsc.ko
depmod -a
echo "=== 加载面板驱动"
modprobe panel-samsung-oneplus-dsc 2>&1
sleep 8
echo "=== DRM 设备"
ls /sys/class/drm 2>/dev/null
echo "=== backlight"
ls /sys/class/backlight/ 2>/dev/null
echo "=== dmesg"
dmesg | grep -iE "panel|dsi|mdss|msm|drm|backlight" | tail -25
' 2>&1 | grep -v Warning | head -50
