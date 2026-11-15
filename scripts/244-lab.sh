#!/bin/bash
set -u
K=/root/kbuild/linux
D=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
echo "=== pm8150l.dtsi 里的 lab/ibb"
grep -n 'lab\|ibb' "$K/arch/arm64/boot/dts/qcom/pm8150l.dtsi" | head -10
echo
echo "=== guac-common 里的 LDO 标签（找 3.3V / 1.8V）"
grep -n 'vreg_l[0-9]*c_' "$D/sm8150-oneplus-common.dtsi" | head -20
echo
echo "=== bob / 2.7V 3.0V 3.1V"
grep -n 'vreg_bob\|vreg_l2a_3p1\|vreg_l17a_3p0\|vreg_l13a_2p7' "$D/sm8150-oneplus-common.dtsi" | head
