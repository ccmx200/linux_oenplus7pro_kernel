#!/bin/bash
set -u
K=/root/kbuild/linux/drivers/gpu/drm/panel
echo "=== 主线 samsung 面板驱动"
ls "$K" | grep -i samsung | head -20
echo
echo "=== ams639 / rq08 相关"
grep -rln 'ams639\|rq08\|639' "$K" 2>/dev/null | head -10
echo
echo "=== 若存在，看它需要的 supply 与模式"
F=$(grep -rl 'ams639' "$K" 2>/dev/null | head -1); echo "file=$F"
[ -n "$F" ] && grep -n 'supply\|static const struct drm_display_mode\|\.clock\|hdisplay\|vdisplay' "$F" | head -20
