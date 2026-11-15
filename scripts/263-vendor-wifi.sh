#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
code=$(curl -sL -o "$W/qcom_sm8150.dtsi" -w '%{http_code}' --max-time 120 "$BASE/qcom/sm8150.dtsi")
echo "$code sm8150.dtsi $(wc -c < "$W/qcom_sm8150.dtsi")b"
echo "=== vendor wifi 节点全文"
grep -n -A45 'wifi@18800000' "$W/qcom_sm8150.dtsi" | head -60
echo
echo "=== xo-cal-data / wlan-enable / power-domain 关键字"
grep -n 'xo-cal-data\|wlan-enable\|wcss\|qcom,wlan' "$W"/*.dtsi | head -20
