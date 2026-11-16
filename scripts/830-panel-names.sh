#!/bin/bash
set -u
V=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== vendor 里所有面板节点名"
grep -rho 'qcom,mdss-dsi-panel-name = "[^"]*"' "$V"/*.dtsi 2>/dev/null | sort -u | head -20
echo
echo "=== 含 samsung/s6e/ams 的行"
grep -rn -iE 'samsung|s6e|ams6' "$V"/*.dtsi 2>/dev/null | head -15
echo
echo "=== 18821 里 dsi_ 面板引用"
grep -n 'dsi_' "$V/18821_sm8150-mtp.dtsi" 2>/dev/null | head -20
