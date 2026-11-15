#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== vendor 里有 wcn3990 / icnss / cnss 的文件"
grep -rln 'wcn3990' "$W"/*.dtsi 2>/dev/null
grep -rn 'qcom,wcn3990-wifi' "$W"/*.dtsi 2>/dev/null | head -5
echo
echo "=== 18821 dts 里 icnss/cnss 的 status"
grep -n -A3 'icnss\|cnss\|wlan' "$W/18821_sm8150-mtp.dtsi" 2>/dev/null | grep -E 'icnss|cnss|status|wlan' | head -20
