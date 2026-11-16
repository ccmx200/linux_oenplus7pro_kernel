#!/bin/bash
set -u
M=/root/kbuild/linux/drivers/gpu/drm/msm
echo "=== drm/msm 里 8150 相关"
grep -rn -e '8150' "$M" --include=*.c --include=*.h | head -30
echo
echo "=== DSI PHY 7nm 支持的 compatible"
grep -rn -e 'compatible' "$M/dsi/phy/dsi_phy_7nm.c" | head -10
echo
echo "=== DPU 目录里的平台表"
grep -rn -e 'sm8150' -e 'SM8150' "$M/disp" 2>/dev/null | head -10
echo
echo "=== dsi_cfg 平台条目"
grep -rn -e 'msm_dsi_cfg' -e '\.name' "$M/dsi/dsi_cfg.c" | head -20
