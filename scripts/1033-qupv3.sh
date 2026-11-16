#!/bin/bash
set -u
D=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== i2c17 定义位置与父节点"
grep -n -B2 -A6 'i2c17:' "$D/sm8150.dtsi" | head -20
echo
echo "=== qupv3 节点"
grep -n 'qupv3_id_[0-9]:' "$D/sm8150.dtsi"
echo
echo "=== 我们的 DTS 是否启用 qupv3"
grep -n 'qupv3' /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-common.dtsi /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-guacamole.dts
echo
echo "=== Nura guac 的 qupv3"
grep -rn 'qupv3' /root/.local/var/pmbootstrap/cache_git/pmaports/device 2>/dev/null | head -3
