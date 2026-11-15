#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
mkdir -p /tmp/vdts
for f in qcom/sm8150-mtp.dtsi qcom/sm8150-pmic-overlay.dtsi qcom/sm8150.dtsi 18821/sm8150-mtp.dtsi 18821/Makefile; do
    out=/tmp/vdts/$(echo "$f" | tr '/' '_')
    code=$(curl -sL -o "$out" -w '%{http_code}' --max-time 120 "$BASE/$f")
    echo "$code $f $(wc -c < "$out" 2>/dev/null)b"
done
echo
echo "=== 18821/Makefile 里 guacamole"
grep -n 'guacamole\|oneplus' /tmp/vdts/18821_Makefile 2>/dev/null | head
echo
echo "=== 显示 & WiFi 关键字（全部文件）"
grep -rn 'vreg_disp\|disp_vci\|ams639\|ea8076\|dsi_panel\|wcn3990\|qca6390\|cnss\|wlan' /tmp/vdts/ 2>/dev/null | head -30
