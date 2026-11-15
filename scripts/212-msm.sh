#!/bin/bash
set -u
S() { sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8 root@172.16.42.1 "$@"; }

echo "=== drm/msm 模块是否存在"
S 'K=$(uname -r); ls /lib/modules/$K/kernel/drivers/gpu/drm/ 2>/dev/null | head; echo ---; ls /lib/modules/$K/kernel/drivers/gpu/drm/msm 2>/dev/null | head; echo ---; ls /lib/modules/$K/kernel/drivers/gpu/drm/panel 2>/dev/null | grep -i samsung | head'
echo
echo "=== 尝试加载 msm"
S 'modprobe msm 2>&1 | head -5; sleep 2; ls /sys/class/drm/; dmesg | tail -25'
