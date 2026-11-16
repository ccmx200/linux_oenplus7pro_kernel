#!/bin/bash
set -u
F=/root/oposs/arch/arm64/boot/dts/qcom/dsi-panel-samsung_oneplus_dsc.dtsi
echo "=== 大小/行数"; wc -l "$F"
echo
echo "=== 关键属性"
grep -n -e 'qcom,mdss-dsi-panel-name' -e 'panel-width' -e 'panel-height' -e 'h-front-porch' -e 'h-back-porch' -e 'h-pulse-width' -e 'v-front-porch' -e 'v-back-porch' -e 'v-pulse-width' -e 'clock-rate' -e 'refresh-rate' -e 'compression' -e 'slice' -e 'platform-reset-gpio' -e 'platform-te-gpio' -e 'panel-supply' -e 'bl-' "$F" | head -40
echo
echo "=== on-command 段（前 40 行）"
grep -n -A40 'qcom,mdss-dsi-on-command = \[' "$F" | head -45
