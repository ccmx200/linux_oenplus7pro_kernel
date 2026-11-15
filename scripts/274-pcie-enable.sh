#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

if ! grep -q '&pcie0' "$C/sm8150-oneplus-guacamole.dts"; then
cat >> "$C/sm8150-oneplus-guacamole.dts" <<'EOF'

/* ---- 第一阶段：只打开 PCIe 控制器，验证总线能否枚举 ---- */
&pcie0 {
	status = "okay";
};
EOF
echo "pcie0 enabled in dts"
fi

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -6
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || echo BUILD_FAIL
