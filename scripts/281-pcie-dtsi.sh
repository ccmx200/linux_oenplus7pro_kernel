#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
code=$(curl -sL -o "$W/qcom_sm8150-pcie.dtsi" -w '%{http_code}' --max-time 120 "$BASE/qcom/sm8150-pcie.dtsi")
echo "$code sm8150-pcie.dtsi $(wc -c < "$W/qcom_sm8150-pcie.dtsi")b"
echo
echo "=== pcie0 节点"
grep -n -A50 'pcie0:' "$W/qcom_sm8150-pcie.dtsi" | head -60
echo
echo "=== perst / wake / supply"
grep -n 'perst\|wake\|vddpe\|vdda\|supply' "$W/qcom_sm8150-pcie.dtsi" | head -20
