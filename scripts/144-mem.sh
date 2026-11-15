#!/bin/bash
set -u
D=/root/uboot/dts/upstream/src/arm64/qcom
echo "=== uboot sm8150.dtsi 里的 memory 节点"
grep -n -A6 'memory@80000000' "$D/sm8150.dtsi" | head -20
echo
echo "=== raphael dts 的 cont_splash_mem"
grep -n -A5 'cont_splash_mem' "$D/sm8150-xiaomi-raphael.dts" | head -12
echo
echo "=== raphael dts 是否有 /memory 覆盖"
grep -n 'device_type = "memory"' "$D/sm8150-xiaomi-raphael.dts" || echo "(无)"
echo
echo "=== 板级 dts 里内存大小来源 sm8150.dtsi memory:"
grep -n -B2 -A8 'device_type = "memory"' "$D/sm8150.dtsi" | head -20
