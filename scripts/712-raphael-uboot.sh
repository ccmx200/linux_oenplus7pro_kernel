#!/bin/bash
set -u
R=/root/raphael-uboot
echo "=== guac dts 文件"
ls "$R/arch/arm/dts" | grep -iE 'guac|oneplus|sm8150' | head -20
echo
echo "=== dts 里 pon/resin/pwrkey/button"
grep -rn 'resin\|pwrkey\|button\|pon@' "$R/arch/arm/dts"/*guac*.dts "$R/arch/arm/dts"/*oneplus*.dtsi 2>/dev/null | head -25
echo
echo "=== dts 里所有 keys 节点"
grep -rn -A6 'keys {' "$R/arch/arm/dts"/*guac*.dts 2>/dev/null | head -30
echo
echo "=== 构建产物"
ls -lh "$R"/u-boot*.bin "$R"/*.img 2>/dev/null | head
