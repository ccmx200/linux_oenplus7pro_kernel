#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
for f in qcom/pm8150.dtsi qcom/pm8150l.dtsi; do
  out="$W/$(echo "$f" | tr '/' '_')"
  code=$(curl -sL -o "$out" -w '%{http_code}' --max-time 90 "$BASE/$f")
  echo "$code $f $(wc -c < "$out")b"
done
echo
echo "=== vendor pm8150/pm8150l 里 wlan/sw_ctrl"
grep -rn 'wlan\|sw_ctrl\|wcss' "$W/qcom_pm8150.dtsi" "$W/qcom_pm8150l.dtsi" 2>/dev/null | head -15
echo
echo "=== vendor 18821 里 pm8150_gpios pinctrl 含 wlan 的"
grep -rn 'wlan' "$W/18821_sm8150-mtp.dtsi" | head -10
