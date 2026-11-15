#!/bin/bash
# 构建 OnePlus 7 Pro 的 U-Boot：基于 raphael 板级 DTS 改显示几何 + guacamole 标识
set -euo pipefail
U=/root/uboot
D=$U/dts/upstream/src/arm64/qcom
OUT=/root/op7p/out
CROSS=aarch64-linux-gnu-

cd "$U"
echo "=== 生成 guacamole dts"
cp -f "$D/sm8150-xiaomi-raphael.dts" "$D/sm8150-oneplus-guacamole.dts"
F=$D/sm8150-oneplus-guacamole.dts
sed -i 's/model = "Xiaomi Redmi K20 Pro";/model = "OnePlus 7 Pro";/' "$F"
sed -i 's/"xiaomi,raphael", "qcom,sm8150"/"oneplus,guacamole", "qcom,sm8150"/' "$F"
# 去掉 raphael 的 msm-id/board-id，避免 ABL 校验不匹配
sed -i '/qcom,msm-id = </d; /qcom,board-id = </d' "$F"
# 显示：1440x3120
sed -i 's/(1080 \* 2340 \* 4)/(1440 * 3120 * 4)/; s/width = <1080>;/width = <1440>;/; s/height = <2340>;/height = <3120>;/; s/(1080 \* 4)/(1440 * 4)/' "$F"
grep -n 'model =\|compatible = "oneplus\|reg = <0 0x9c000000\|width =\|height =\|stride =\|format =' "$F" | head -10
grep -n 'cont_splash_mem' -A4 "$F" | head -8

echo "=== 配置并编译"
make distclean >/dev/null 2>&1 || true
make O=.output CROSS_COMPILE=$CROSS qcom_defconfig qcom-phone.config tauchgang.config >/dev/null
make O=.output CROSS_COMPILE=$CROSS -j"$(nproc)" CONFIG_DEFAULT_DEVICE_TREE=qcom/sm8150-oneplus-guacamole 2>&1 | tail -12

echo "=== 产物"
ls -l .output/u-boot-nodtb.bin .output/dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb 2>/dev/null || true
