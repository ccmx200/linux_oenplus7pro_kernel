#!/bin/bash
set -u
U=/root/uboot
echo "=== U-Boot 里 resin / button 驱动"
grep -rln 'resin' "$U/drivers" 2>/dev/null | head -10
echo
echo "=== button-qcom-pmic 关键逻辑"
F=$(find "$U/drivers" -name '*button*qcom*' -o -name '*qcom*button*' | head -1); echo "file=$F"
[ -n "$F" ] && grep -n 'resin\|RESIN\|volume\|state\|bit' "$F" | head -30
echo
echo "=== 我们 guac DTS 里的 pon/resin/key 节点"
grep -rn 'resin\|pon\|pwrkey\|key-vol\|volume' "$U/arch/arm/dts/sm8150-oneplus-guacamole.dts" "$U/arch/arm/dts/sm8150-oneplus-common.dtsi" 2>/dev/null | head -20
