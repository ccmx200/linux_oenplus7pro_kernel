#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== mainline pcie 标签"
grep -n 'pcie[0-9]*:\|pcie_phy\|pcie@1c0' "$K/sm8150.dtsi" | head -12
echo
echo "=== vendor pcie@1c00000 节点（前 60 行）"
grep -n -A60 'pcie0:.*pcie@1c00000\|pcie@1c00000 {' "$W/qcom_sm8150.dtsi" | head -70
echo
echo "=== vendor 里 pcie 相关供电/phy"
grep -n 'vddpe\|pcie_phy\|pcie0_phy\|pcie1_phy' "$W/qcom_sm8150.dtsi" "$W/18821_sm8150-mtp.dtsi" | head -15
