#!/bin/bash
set -u
V=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor/qcom_sm8150.dtsi
sed -n '3700,3770p' "$V"
echo "......"
sed -n '3820,3870p' "$V"
