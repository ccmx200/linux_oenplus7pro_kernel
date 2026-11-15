#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== mainline 里 swctrl-gpios 用法"
grep -rn 'swctrl-gpios' "$K"/*.dts* | head -8
echo
echo "=== OnePlus 6T 的 sw_ctrl"
grep -n -B3 -A8 'sw_ctrl\|swctrl' "$K/sdm845-oneplus-common.dtsi" | head -30
echo
echo "=== vendor sm8150 dtsi 里 sw_ctrl / wlan_en"
grep -rn 'sw_ctrl\|swctrl\|wlan_en\|wlan-en' "$W"/*.dtsi | head -15
