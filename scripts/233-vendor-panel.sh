#!/bin/bash
set -u
F=/tmp/vdts/18821_sm8150-mtp.dtsi
echo "=== dsi_panel_pwr_supply 定义（pmic-overlay）"
grep -n -A14 'dsi_panel_pwr_supply' /tmp/vdts/qcom_sm8150-pmic-overlay.dtsi 2>/dev/null | head -40
echo
echo "=== 18821 dts 里 panel 与 supply 引用"
sed -n '240,320p' "$F" 2>/dev/null
