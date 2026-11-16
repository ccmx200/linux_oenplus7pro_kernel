#!/bin/bash
set -u
V=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== vendor 里的面板节点名"
grep -rn 'mdss_dsi.*samsung\|ams639\|qcom,mdss-dsi-panel-name' "$V"/*.dtsi 2>/dev/null | head -10
echo
echo "=== 面板关键参数（timing/分辨率/命令数）"
grep -rn -A6 'qcom,mdss-dsi-panel-name' "$V"/*.dtsi 2>/dev/null | head -20
echo
echo "=== 是否有 init 序列"
grep -rc 'qcom,mdss-dsi-on-command' "$V"/*.dtsi 2>/dev/null | head
echo
echo "=== PANEL_NOTES.md 摘要"
head -40 "$V/PANEL_NOTES.md" 2>/dev/null
