#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

echo "=== PM8150L usid"
grep -n -B2 -A3 'qcom,pm8150l"' "$D/pm8150l.dtsi" | head -10

echo "=== 同步 dts 到内核树"
cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
grep -c 'ams639rq08' "$D/sm8150-oneplus-guacamole.dts"

echo "=== 重编"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -15
ls -lh "$D/sm8150-oneplus-guacamole.dtb" || exit 1
