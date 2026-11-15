#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
mkdir -p "$W"
code=$(curl -sL -o "$W/qcom_pm8150l.dtsi" -w '%{http_code}' --max-time 120 "$BASE/qcom/pm8150l.dtsi")
echo "$code qcom/pm8150l.dtsi $(wc -c < "$W/qcom_pm8150l.dtsi")b"
echo
echo "=== lab / ibb 节点"
grep -n -A18 'lab@\|ibb@' "$W/qcom_pm8150l.dtsi" | head -60
echo
echo "=== 相关 compatible"
grep -n 'lab-ibb\|qcom,lab\|qcom,ibb' "$W/qcom_pm8150l.dtsi" | head
