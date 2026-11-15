#!/bin/bash
set -u
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
echo "=== vendor sm8150.dtsi 里 pcie 相关行"
grep -n 'pcie' "$W/qcom_sm8150.dtsi" | head -20
echo
echo "=== 18821 / mtp 里的 pcie 覆盖"
grep -n 'pcie' "$W/18821_sm8150-mtp.dtsi" "$W/qcom_sm8150-mtp.dtsi" | head -20
