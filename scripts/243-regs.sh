#!/bin/bash
set -u
D=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
echo "=== guac-common 里的 regulator / 显示相关（140-210 行）"
sed -n '140,210p' "$D/sm8150-oneplus-common.dtsi"
echo
echo "=== 是否有 lab/ibb/vreg_l*"
grep -n 'lab\|ibb\|vreg_l\|vdd3p3\|vddio' "$D/sm8150-oneplus-common.dtsi" | head -25
echo
echo "=== guacamole.dts 内容"
cat "$D/sm8150-oneplus-guacamole.dts"
