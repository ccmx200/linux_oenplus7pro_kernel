#!/bin/bash
set -u
K=/root/op7p/work/linux
D=$K/arch/arm64/boot/dts/qcom
echo "=== 内核树里所有 rpmh-regulator 节点（源码）"
grep -rn "rpmh-regulators" "$D"/*.dts "$D"/*.dtsi 2>/dev/null | head -20
echo
echo "=== 反编译我们的 DTB"
dtc -I dtb -O dts "$D/sm8150-oneplus-guacamole.dtb" -o /tmp/guac.dts 2>/dev/null
grep -n "rpmh-regulators" /tmp/guac.dts | head -10
echo
echo "=== 每个容器的 no-readback / pmic-id"
grep -n -B3 -A3 "rpmh-regulators\"" /tmp/guac.dts | grep -E 'rpmh-regulators|pmic-id|no-readback|compatible' | head -20
echo
echo "=== raphael dts 的 regulators 节点名"
grep -n "regulators-" "$D/sm8150-xiaomi-raphael.dts" | head
