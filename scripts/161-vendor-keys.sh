#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
mkdir -p /tmp/vdts
for f in qcom/sm8150-pmic-overlay.dtsi qcom/sm8150-mtp.dtsi 18821/guacamole.dtsi 18821/sm8150-mtp.dtsi; do
    out=/tmp/vdts/$(echo "$f" | tr '/' '_')
    code=$(curl -sL -o "$out" -w '%{http_code}' --max-time 120 "$BASE/$f")
    echo "$code $f ($(wc -c < "$out" 2>/dev/null) bytes)"
done
echo
echo "=== KEY_VOLUME / gpio-keys / pm8150_gpios in vendor dts"
grep -rn 'KEY_VOLUME\|key-vol\|gpio-keys\|pm8150_gpios\|pm8150l_gpios' /tmp/vdts/ 2>/dev/null | head -30
