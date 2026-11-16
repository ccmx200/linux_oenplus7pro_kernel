#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 主线 sm8150.dtsi 里 wifi/msa 相关"
grep -n -B2 -A12 'wifi@18800000' "$K/arch/arm64/boot/dts/qcom/sm8150.dtsi" | head -40
echo "=== 保留内存 wlan"
grep -n 'wlan' "$K/arch/arm64/boot/dts/qcom/sm8150.dtsi" | head -10
echo "=== 我们 DTS 里的 msa"
grep -n 'msa' /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-guacamole.dts /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-common.dtsi | head
echo "=== qmi.c 里 msa info"
grep -n -A20 'ath10k_qmi_msa_info_send_sync' "$K/drivers/net/wireless/ath/ath10k/qmi.c" | head -30
