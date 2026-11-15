#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== dsi_panel_pwr_supply 定义位置"
grep -rn 'dsi_panel_pwr_supply' "$W" | head -10
echo
echo "=== 定义内容（含 regulator 列表）"
grep -n -A25 'dsi_panel_pwr_supply:' "$W"/*.dtsi | head -40
echo
echo "=== vsp/vsn/lab/ibb 相关"
grep -n 'vsp\|vsn\|lab\|ibb' "$W"/*.dtsi | head -20
