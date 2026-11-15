#!/bin/bash
# 在 6.4 的 guac DTS 里关掉不需要的 remoteproc/GPU/WiFi/IPA，避免无 initramfs 时的固件超时
set -euo pipefail
SRC=/root/nura-kernel/linux
D=$SRC/arch/arm64/boot/dts/qcom
ARCH=arm64
CROSS=aarch64-linux-gnu-

echo "=== 确认节点存在"
for l in remoteproc_mpss remoteproc_adsp remoteproc_slpi remoteproc_cdsp remoteproc_venus gpu wifi ipa; do
    if grep -q "^	$l:" "$D/sm8150.dtsi"; then echo "OK $l"; else echo "?? $l (可能不需要)"; fi
done

echo "=== 追加 disable 覆盖"
cat >> "$D/sm8150-oneplus-guacamole.dts" <<'EOF'

/* 首启最小化：关掉需要固件的子系统，避免没有 initramfs 时的 60s 超时 */
&remoteproc_mpss { status = "disabled"; };
&remoteproc_adsp { status = "disabled"; };
&remoteproc_slpi { status = "disabled"; };
&remoteproc_cdsp { status = "disabled"; };
&remoteproc_venus { status = "disabled"; };
&gpu { status = "disabled"; };
&wifi { status = "disabled"; };
&ipa { status = "disabled"; };
EOF

echo "=== 重新编 dtbs"
cd "$SRC"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" dtbs 2>&1 | tail -5
ls -l arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
