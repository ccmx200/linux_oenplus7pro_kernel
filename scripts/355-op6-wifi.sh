#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== OnePlus 6T (fajita) 的 wifi 配置（同为 WCN3990 SNOC）"
grep -n -A25 '&wifi' "$K/sdm845-oneplus-common.dtsi" | head -40
echo
echo "=== 是否有 pwrseq"
grep -n 'pwrseq\|wcn3998-pmu' "$K/sdm845-oneplus-common.dtsi" | head
