#!/bin/bash
set -u
DTB=/root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$DTB" -o /tmp/gd.dts 2>/dev/null
echo "=== display / dsi / panel"
grep -n -A6 'display-subsystem@ae00000 {' /tmp/gd.dts | head -12
echo "--- dsi"
grep -n -A4 'dsi@ae94000 {' /tmp/gd.dts | head -10
echo "--- panel 节点"
grep -n 'panel@\|panel {' /tmp/gd.dts | head -5
grep -n 'compatible = "samsung' /tmp/gd.dts | head -5
echo "--- 显示相关 status"
awk '/display-subsystem@ae00000 \{/,/^\t\t\};/' /tmp/gd.dts | grep -E 'status|compatible' | head
echo
echo "=== wifi 节点"
grep -n -A8 'wifi@18800000 {' /tmp/gd.dts | head -14
echo
echo "=== dsi 供电 regulator"
grep -n 'vdda_dsi' /tmp/gd.dts | head -8
