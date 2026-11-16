#!/bin/bash
set -u
M=/root/kbuild/linux/drivers/gpu/drm/msm
echo "=== phy 目录文件"
ls "$M/dsi/phy/" 2>/dev/null | head
echo
echo "=== 全树搜 dsi-phy-7nm-8150"
grep -rn 'dsi-phy-7nm-8150' /root/kbuild/linux --include=*.c --include=*.h --include=*.dtsi 2>/dev/null | head -10
echo
echo "=== dsi_phy_7nm 里的支持表"
F=$(ls "$M"/dsi/phy/dsi_phy_7nm*.c 2>/dev/null | head -1); echo "file=$F"
grep -n -e 'sm8150' -e 'sm8250' -e 'cfg' -e 'static const struct' "$F" 2>/dev/null | head -20
echo
echo "=== dsi_cfg 里 8150"
grep -rn '8150' "$M/dsi/dsi_cfg.c" "$M/dsi/dsi_cfg.h" 2>/dev/null | head -10
