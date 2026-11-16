#!/bin/bash
set -u
F=/root/oposs/arch/arm64/boot/dts/qcom/sm8150-sde-display.dtsi
echo "=== 面板供电列表"
grep -n -A30 'dsi_panel_pwr_supply: dsi_panel_pwr_supply' "$F" | head -50
echo
echo "=== dsi_display / mdss 关键属性"
grep -n -e 'qcom,mdss-dsi' -e 'regulator' -e 'vsp' -e 'vsn' -e 'lab' -e 'ibb' "$F" | head -20
