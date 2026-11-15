#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== 主线是否有这些 label"
for l in vreg_s4a_1p8 vreg_l10c_3p3 vreg_l7a_1p8 vreg_l2c_1p3 vreg_l11c_3p3; do
  printf "%-18s " "$l"; grep -rl "$l:" "$K"/*.dtsi 2>/dev/null | head -1 || true; echo
done
echo
echo "=== OnePlus 6T sw_ctrl_default 完整定义"
sed -n "$(grep -n 'sw_ctrl_default: sw-ctrl-default-state' "$K/sdm845-oneplus-common.dtsi" | cut -d: -f1),+12p" "$K/sdm845-oneplus-common.dtsi"
