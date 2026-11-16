#!/bin/bash
set -u
D=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== 启用 mdss_dsi0 的 dts"
grep -ln 'mdss_dsi0 {' "$D"/*.dts 2>/dev/null | head -10
echo
echo "=== sm8150-hdk 显示节点"
grep -n -A8 -e '&mdss ' -e '&mdss {' -e '&mdss_dsi0' -e '&mdss_dsi0_phy' "$D/sm8150-hdk.dts" 2>/dev/null | head -40
