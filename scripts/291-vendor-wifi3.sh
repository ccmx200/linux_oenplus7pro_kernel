#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== 在 vendor 全量 dtsi 里找 wcn3990-wifi（fixed string）"
grep -rnF 'wcn3990-wifi' "$W" 2>/dev/null | head
echo
echo "=== vendor sm8150.dtsi 里 wifi 节点（18800000）"
grep -n '18800000' "$W/qcom_sm8150.dtsi" | head
L=$(grep -n '18800000' "$W/qcom_sm8150.dtsi" | head -1 | cut -d: -f1)
[ -n "${L:-}" ] && sed -n "$((L-30)),$((L+25))p" "$W/qcom_sm8150.dtsi"
