#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== OnePlus 6T (fajita) 里的 lab/ibb 写法"
grep -n -B3 -A20 'lab-ibb' "$K/sdm845-oneplus-common.dtsi" "$K/sdm845-oneplus-fajita.dts" 2>/dev/null | head -40
echo
echo "=== pm8150l.dtsi 里是否有 lab/ibb 外设地址"
grep -n -A6 'lab@\|ibb@\|lab-ibb' "$K/pm8150l.dtsi" | head -20
