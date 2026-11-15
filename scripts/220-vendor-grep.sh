#!/bin/bash
set -u
ls -lh /tmp/vdts 2>/dev/null
F=/tmp/vdts/18821_sm8150-mtp.dtsi
echo "=== 显示相关（panel/dsi/供电）"
grep -n 'panel\|dsi\|mdss\|vreg_disp\|disp_vci\|vdd.*disp\|ams639\|ea8076\|td4320' "$F" 2>/dev/null | head -40
echo
echo "=== WiFi / WLAN 相关"
grep -n 'wifi\|wlan\|wcn\|qca\|cnss\|wifi3\|wifi0' "$F" 2>/dev/null | head -40
