#!/bin/bash
set -u
D=/root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616
echo "=== 0015 补丁中的 mdss/dsi/panel 相关 hunk"
grep -n -e 'mdss' -e 'dsi' -e 'panel' -e 'display' "$D/0015-arm64-dts-hotdog-source-v43-hardware-contract.patch" | head -40
echo
echo "=== 0015 补丁头部"
head -40 "$D/0015-arm64-dts-hotdog-source-v43-hardware-contract.patch"
