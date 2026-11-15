#!/bin/bash
set -u
echo "=== 构建内核里的 DRM 配置"
grep -E '^CONFIG_(DRM|DRM_MSM|DRM_FBDEV|FB_SIMPLE|FB=|FRAMEBUFFER_CONSOLE)' /root/kbuild/linux/.config | head -20
echo
echo "=== raphael.config 里的 DRM_MSM"
grep -n 'DRM_MSM\|DRM_PANEL_SAMSUNG\|FB_SIMPLE' /root/kernel-deb/raphael.config | head -10
echo
echo "=== 源码是否有 msm 驱动"
ls /root/kbuild/linux/drivers/gpu/drm/msm/ 2>/dev/null | head -5
