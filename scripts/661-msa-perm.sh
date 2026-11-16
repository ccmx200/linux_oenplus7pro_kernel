#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 内核里 msa-fixed-perm 的使用"
grep -rn 'msa-fixed-perm\|msa_fixed_perm' "$K/drivers/net/wireless/ath/ath10k/" | head -10
echo
echo "=== 各 DTS 里是否有该属性"
grep -rn 'msa-fixed-perm' "$K/arch/arm64/boot/dts/qcom/" | head -10
echo
echo "=== sm8150-hdk wifi 节点"
grep -n -A20 '&wifi' "$K/arch/arm64/boot/dts/qcom/sm8150-hdk.dts" | head -30
