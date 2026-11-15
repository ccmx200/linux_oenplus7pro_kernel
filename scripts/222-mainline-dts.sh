#!/bin/bash
set -u
D=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
echo "=== 我们手上的 mainline guac dts 里显示/供电/WiFi"
grep -n 'vreg_disp\|disp_vci\|dsi\|panel\|mdss\|wifi\|wcn\|ath10k' "$D"/*.dts* 2>/dev/null | head -40
echo
echo "=== 文件列表"
ls -lh "$D"
