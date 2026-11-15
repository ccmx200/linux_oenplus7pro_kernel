#!/bin/bash
set -u
D=/root/op7p/work/linux/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$D" -o /tmp/g3.dts 2>/dev/null
echo "=== memory 节点"
grep -n -A5 'memory@80000000' /tmp/g3.dts | head -12
echo
echo "=== reserved-memory 里与 0x9c000000 相关的"
grep -n -B3 -A6 '0x9c000000' /tmp/g3.dts | head -40
echo
echo "=== reserved-memory 全部子节点"
sed -n "$(grep -n 'reserved-memory {' /tmp/g3.dts | head -1 | cut -d: -f1),+8p" /tmp/g3.dts
echo
echo "=== raphael 同项: memory/fb 大小"
grep -n '0x9c000000' /root/op7p/work/linux/arch/arm64/boot/dts/qcom/sm8150-xiaomi-raphael.dts | head
