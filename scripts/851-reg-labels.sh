#!/bin/bash
set -u
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
echo "=== 我们 DTS 里的 l3c / l5a 标签"
grep -n -e 'l3c' -e 'l5a' "$C/sm8150-oneplus-common.dtsi" "$C/sm8150-oneplus-guacamole.dts" | head -15
echo
echo "=== 0015 里 &mdss / &mdss_mdp 的 hunk"
grep -n -B2 -A8 '&mdss_mdp' /root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616/0015-arm64-dts-hotdog-source-v43-hardware-contract.patch | head -40
echo
echo "=== 0015 里 &mdss { 附近"
grep -n -A6 '^ &mdss {' /root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616/0015-arm64-dts-hotdog-source-v43-hardware-contract.patch | head -20
