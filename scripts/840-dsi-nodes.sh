#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150.dtsi
echo "=== dsi0 节点（4093-4168）"
sed -n '4093,4168p' "$K"
echo "=== dsi0_phy 节点（4169-4210）"
sed -n '4169,4210p' "$K"
