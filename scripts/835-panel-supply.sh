#!/bin/bash
set -uo pipefail
F=/root/oposs/arch/arm64/boot/dts/qcom/dsi-panel-samsung_oneplus_dsc.dtsi
echo "=== 供电/GPIO/背光 属性"
grep -n -e 'supply-entries' -e 'panel-supply' -e 'reset-gpio' -e 'te-gpio' -e 'bl-pmic' -e 'panel-mode-gpio' -e 'vdd' -e 'lab' -e 'ibb' "$F" | head -20
echo
echo "=== 18821 里 oneplus dsc 面板的引用"
grep -n -A12 'dsi_samsung_oneplus_dsc_cmd' /root/oposs/arch/arm64/boot/dts/qcom/sm8150-oneplus*.dtsi 2>/dev/null | head -30
