#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== oneplus common 里 wlan/wcss"
grep -n 'wlan\|wcss' "$K/sdm845-oneplus-common.dtsi" | head -20
echo
echo "=== sdm845.dtsi 里 wlan/wcss"
grep -n 'wlan\|wcss' "$K/sdm845.dtsi" | head -20
echo
echo "=== sm8150.dtsi 里 wlan/wcss/wifi"
grep -n 'wlan\|wcss\|wifi@' "$K/sm8150.dtsi" | head -20
