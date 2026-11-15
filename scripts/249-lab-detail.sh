#!/bin/bash
set -u
V=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor/qcom_pm8150l.dtsi
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== vendor pm8150l 里 400-437 行"
sed -n '395,437p' "$V"
echo
echo "=== mainline 里有谁用 qcom,pmi8998-lab-ibb"
grep -rn 'pmi8998-lab-ibb' "$K"/*.dts* 2>/dev/null | head -5
echo
echo "=== 驱动需要的属性"
grep -n 'of_property_read\|reg-names\|qcom,' /root/kbuild/linux/drivers/regulator/qcom-labibb-regulator.c | head -20
