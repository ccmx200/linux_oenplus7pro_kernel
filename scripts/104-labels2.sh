#!/bin/bash
set -u
D=/root/nura-kernel/linux/arch/arm64/boot/dts/qcom
echo "--- sm8150.dtsi 中 remoteproc 相关"
grep -n "remoteproc" "$D/sm8150.dtsi" | head -20
echo "--- 4080000 上下文"
grep -n -B4 -A6 "4080000" "$D/sm8150.dtsi" | head -30
echo "--- common dtsi 中 &remoteproc/&wifi/&ipa/&gpu"
grep -n -E '&(remoteproc[a-z_]*|wifi|ipa|gpu)\b' "$D/sm8150-oneplus-common.dtsi" | head -20
echo "--- common dtsi 中 status disabled/okay 位置（前 40 行含 & 的块）"
grep -n -A2 -E '^&[a-z]' "$D/sm8150-oneplus-common.dtsi" | head -60
