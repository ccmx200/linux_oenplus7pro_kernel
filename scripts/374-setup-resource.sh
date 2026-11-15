#!/bin/bash
set -u
S=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c
echo "=== setup_resource"
sed -n "$(grep -n 'static int ath10k_snoc_setup_resource' "$S" | cut -d: -f1),+45p" "$S"
echo
echo "=== smd/glink in sm8150.dtsi"
grep -n 'smd\|glink' /root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150.dtsi | head
echo
echo "=== smd/glink in sdm845.dtsi"
grep -n 'smd\|glink' /root/kbuild/linux/arch/arm64/boot/dts/qcom/sdm845.dtsi | head
