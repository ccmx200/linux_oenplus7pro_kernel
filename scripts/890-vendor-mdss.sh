#!/bin/bash
set -u
D=/root/oposs/arch/arm64/boot/dts/qcom
echo "=== 官方 mdss 节点（display-subsystem）"
grep -rn -A25 'display-subsystem@ae00000' "$D"/sm8150*.dtsi 2>/dev/null | head -40
echo
echo "=== 官方 dsi_panel_pwr_supply 定义"
grep -rn -A25 'dsi_panel_pwr_supply:' "$D"/*.dtsi 2>/dev/null | head -35
echo
echo "=== 官方 label/GPIO 供电（panel-supply-entries 引用）"
grep -rn 'panel-supply-entries' "$D"/sm8150-oneplus*.dtsi "$D"/dsi-panel-samsung_oneplus_dsc.dtsi 2>/dev/null | head
