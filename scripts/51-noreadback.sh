#!/bin/bash
set -u
K=/root/op7p/work/linux
echo "=== raphael dts: no-readback 位置与所在节点"
grep -n "no-readback" "$K/arch/arm64/boot/dts/qcom/sm8150-xiaomi-raphael.dts"
for n in $(grep -n "no-readback" "$K/arch/arm64/boot/dts/qcom/sm8150-xiaomi-raphael.dts" | cut -d: -f1); do
    echo "--- around line $n"
    sed -n "$((n-14)),$((n+2))p" "$K/arch/arm64/boot/dts/qcom/sm8150-xiaomi-raphael.dts" | grep -E 'regulators|compatible|pmic-id|no-readback'
done
echo
echo "=== 全树搜索 no-readback"
grep -rn "no-readback" "$K/drivers" "$K/Documentation" 2>/dev/null | head -10
echo
echo "=== regulator 驱动文件"
ls "$K/drivers/regulator/" | grep -i rpmh
grep -n "readback\|read_back\|regulator_get_voltage\|rpmh_regulator_vreg" "$K/drivers/regulator/qcom-rpmh-regulator.c" | head -20
