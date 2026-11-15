#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== vendor dts 里 IPCR / wlan glink"
grep -rn 'IPCR' "$W"/*.dtsi 2>/dev/null | head -10
echo
echo "=== vendor dts 里 glink 通道列表"
grep -rn 'qcom,glink-channels' "$W"/*.dtsi 2>/dev/null | head -15
echo
echo "=== 主线 sm8150 glink 通道"
grep -n 'qcom,glink-channels' /root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150.dtsi | head -15
