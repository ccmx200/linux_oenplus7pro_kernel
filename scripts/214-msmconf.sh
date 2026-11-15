#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== .config DRM_MSM"
grep -E '^CONFIG_DRM_MSM' "$K/.config"
echo
echo "=== vmlinux 里是否有 msm 驱动符号"
if [ -f "$K/vmlinux" ]; then
    strings "$K/vmlinux" 2>/dev/null | grep -m3 -i 'msm_dpu\|msm_dsi\|dpu_kms'
fi
echo
echo "=== 设备端检查 built-in msm"
sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1 \
  'dmesg | grep -icE "msm|dpu"; dmesg | grep -iE "msm|dpu|drm" | head -20; ls /sys/bus/platform/drivers | grep -iE "msm|dpu|disp"' 2>&1 | tail -25
