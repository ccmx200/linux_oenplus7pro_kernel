#!/bin/bash
# 把 mainline guac dts 放进 7.3 树并编译 dtb
set -euo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
SRC=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

cp -f "$SRC/sm8150-oneplus-common.dtsi" "$D/"
cp -f "$SRC/sm8150-oneplus-guacamole.dts" "$D/"

echo "=== common dtsi 的 include 检查"
grep -n '#include' "$D/sm8150-oneplus-common.dtsi" "$D/sm8150-oneplus-guacamole.dts" | head -20
for inc in $(grep -ho '#include "[^"]*"' "$D/sm8150-oneplus-common.dtsi" "$D/sm8150-oneplus-guacamole.dts" | sed 's/.*"\(.*\)"/\1/'); do
    [ -f "$D/$inc" ] || echo "缺失: $inc"
done

echo "=== 加 Makefile 条目"
grep -q 'sm8150-oneplus-guacamole.dtb' "$D/Makefile" || \
    echo 'dtb-$(CONFIG_ARCH_QCOM)	+= sm8150-oneplus-guacamole.dtb' >> "$D/Makefile"
grep -n 'oneplus-guacamole' "$D/Makefile"

echo "=== 编译 dtb"
cd "$K"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -25
ls -lh "$K/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" 2>/dev/null || echo "DTB 未生成"
