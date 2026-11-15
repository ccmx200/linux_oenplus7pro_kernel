#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
mkdir -p /tmp/vdts
for f in qcom/sm8150-pmic-overlay.dtsi qcom/sm8150-mtp.dtsi 18821/guacamole.dtsi; do
    out=/tmp/vdts/$(echo "$f" | tr '/' '_')
    code=$(curl -s -o "$out" -w '%{http_code}' --max-time 90 "$BASE/$f")
    echo "$code $f ($(wc -c < "$out" 2>/dev/null) bytes)"
done
echo "=== 按键定义"
grep -rn 'KEY_VOLUME\|key-vol\|gpio-keys\|pm8150_gpios\|pm8150l_gpios' /tmp/vdts/ 2>/dev/null | head -30
echo
echo "=== U-Boot 是否支持 pm8941 resin key"
grep -rln 'pm8941-resin\|pm8941_pwrkey\|qcom,pm8941-resin' /root/uboot/drivers /root/uboot/dts/upstream/src/arm64/qcom/*.dtsi 2>/dev/null | head -10
