#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 设备树状态"
for p in display-subsystem@ae00000 dsi@ae94000; do
  f=/proc/device-tree/soc@0/$p
  echo "$p: $(tr -d "\0" < $f/status 2>/dev/null || echo missing)"
done
echo "=== platform 驱动绑定"
ls /sys/bus/platform/drivers/ | grep -iE "msm|mdss|dsi|disp" | head
readlink /sys/bus/platform/devices/ae00000.display-subsystem/driver 2>/dev/null || echo "mdss unbound"
readlink /sys/bus/platform/devices/ae94000.dsi/driver 2>/dev/null || echo "dsi unbound"
echo "=== 内核 config 里的 DRM_MSM"
zcat /proc/config.gz 2>/dev/null | grep -E "CONFIG_DRM_MSM|CONFIG_DRM=" | head -5 || echo "no config.gz"
echo "=== dmesg 全部 drm/msm 关键字"
dmesg | grep -iE "drm|msm|adreno|gpu" | tail -15
' 2>&1 | grep -v Warning | head -50
