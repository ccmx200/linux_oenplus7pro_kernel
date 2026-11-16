#!/bin/bash
set -u
U=/root/uboot
D=$U/arch/arm/dts
echo "=== u-boot 里 guac 相关 dts"
ls "$D" | grep -iE 'sm8150.*(oneplus|guac)' | head
echo
echo "=== u-boot sm8150 dtsi 里 pon/resin/pwrkey"
grep -rn 'resin\|pwrkey\|pon@' "$D"/*sm8150*.dtsi 2>/dev/null | head -20
echo
echo "=== button-qcom-pmic 支持的 compatible 列表"
grep -n -A3 'compatible = "qcom' "$U/drivers/button/button-qcom-pmic.c" | head -40
echo
echo "=== u-boot 里 pm8150 pon 节点（任意 dts）"
grep -rn 'pm8150.*pon\|pon@c000' "$D" 2>/dev/null | head -10
