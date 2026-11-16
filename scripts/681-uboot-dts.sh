#!/bin/bash
set -u
U=/root/uboot
D=$U/arch/arm/dts
echo "=== guac u-boot dts 文件"
ls "$D" | grep -i 'sm8150.*oneplus\|oneplus.*sm8150' | head
echo
echo "=== u-boot 里 sm8150 pmic pon / resin / pwrkey 定义"
grep -rn 'resin\|pon_pwrkey\|pon-resin\|pwrkey' "$D"/sm8150*.dtsi 2>/dev/null | head -20
echo
echo "=== button-qcom-pmic 支持的 compatible 与 status_bit"
sed -n '30,110p' /root/uboot/drivers/button/button-qcom-pmic.c
echo
echo "=== guac dts 是否 override 了 button"
grep -rn 'button\|keys\|vol' "$D"/sm8150-oneplus-guacamole.dts 2>/dev/null | head
