#!/bin/bash
set -u
K=/root/op7p/work/linux
D=$K/arch/arm64/boot/dts/qcom
echo "=== 7.3 sm8150.dtsi: rsc / rpmhcc nodes"
grep -n "rsc@\|rpmhcc\|qcom,tcs\|drv-id\|cmd-db\|tcs-offset" "$D/sm8150.dtsi" | head -30
echo
echo "=== 7.3 sm8150.dtsi: usb_1_dwc3 clocks"
sed -n "$(grep -n 'usb_1_dwc3:' "$D/sm8150.dtsi" | head -1 | cut -d: -f1),+40p" "$D/sm8150.dtsi" 2>/dev/null | grep -E 'clocks|clock-names|compatible|status' | head
echo
echo "=== guac-common 里的 &apps_rsc / regulator / usb 片段"
grep -n -A20 '^&apps_rsc' "$D/sm8150-oneplus-common.dtsi" 2>/dev/null | head -30
echo "--- 是否有 tcs/drv-id 覆盖"
grep -n "tcs\|drv-id\|rsc" "$D/sm8150-oneplus-common.dtsi" 2>/dev/null | head -20
echo
echo "=== raphael 7.3 dts 里的 &apps_rsc 覆盖（对照，它是能跑的）"
grep -n -A12 '^&apps_rsc' "$D/sm8150-xiaomi-raphael.dts" | head -20
echo
echo "=== 解包 DTB 里的 rsc 节点"
grep -n -B2 -A18 "rsc@18" /tmp/guac.dts | head -60
