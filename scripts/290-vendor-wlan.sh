#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== 18821 dts 里 wlan/wifi 节点"
grep -n 'wlan\|wifi\|wcn3990' "$W/18821_sm8150-mtp.dtsi" | head -20
echo
echo "=== qcom sm8150-mtp.dtsi 里 wlan/wifi 节点"
grep -n 'wlan\|wifi\|wcn3990' "$W/qcom_sm8150-mtp.dtsi" | head -20
echo
echo "=== 18821 里 wlan 节点上下文"
L=$(grep -n 'wlan:' "$W/18821_sm8150-mtp.dtsi" | head -1 | cut -d: -f1)
[ -n "${L:-}" ] && sed -n "${L},$((L+40))p" "$W/18821_sm8150-mtp.dtsi"
