#!/bin/bash
set -u
U=/root/uboot
D=$U/dts/upstream/src/arm64/qcom
echo "=== raphael u-boot dts 里的 pon / 按键覆盖"
grep -n -A12 '&pon\b\|&pon_pwrkey\|&pon_resin\|gpio-keys' "$D/sm8150-xiaomi-raphael.dts" | sed -n '1,80p'
echo
echo "=== pm8150.dtsi / sm8150.dtsi 里的 pon 节点"
grep -rn -A12 'pon@800\|pon:' "$D/pm8150.dtsi" "$D/sm8150.dtsi" 2>/dev/null | head -30
