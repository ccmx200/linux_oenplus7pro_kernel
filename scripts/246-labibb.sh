#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== labibb 驱动与配置"
ls "$K/drivers/regulator/" | grep -i lab
grep -E '^CONFIG_REGULATOR_QCOM_LABIBB' "$K/.config"
echo
echo "=== 驱动 compatible"
grep -n 'compatible\|of_match' "$K/drivers/regulator/qcom-labibb-regulator.c" 2>/dev/null | head -8
echo
echo "=== 树里有哪些 dts 用了 labibb"
grep -rln 'lab-ibb\|labibb\|pmi8998-lab' "$K/arch/arm64/boot/dts/qcom/" 2>/dev/null | head -5
