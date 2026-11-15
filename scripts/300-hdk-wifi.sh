#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== sm8150-hdk 里的 wifi / bluetooth / pwrseq"
grep -n -A40 '&wifi\|wifi {' "$K/sm8150-hdk.dts" | head -60
echo
echo "=== pwrseq 相关"
grep -n 'pwrseq\|power-sequenc' "$K/sm8150-hdk.dts" | head -10
echo
echo "=== 驱动里 pwrseq / vddio 支持"
grep -rn 'pwrseq\|vdd-io\|vddio' /root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c | head -12
