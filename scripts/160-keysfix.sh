#!/bin/bash
# 修音量下：PM8150 PON 是 gen3，resin 用 pmk8350-resin(bit6) 而不是 pm8941-resin(bit1)
set -euo pipefail
U=/root/uboot
F=$U/dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dts

python3 - "$F" <<'PY'
import sys
p=sys.argv[1]
s=open(p).read()
old="""&pon_resin {
	linux,code = <KEY_VOLUMEDOWN>;

	status = "okay";
};"""
new="""&pon_resin {
	/* PM8150 的 PON 是 gen3：resin 状态位是 bit6，用 pmk8350 绑定才能读对 */
	compatible = "qcom,pmk8350-resin";
	linux,code = <KEY_VOLUMEDOWN>;

	status = "okay";
};"""
assert old in s, "pon_resin block not found"
open(p,'w').write(s.replace(old,new,1))
print("patched resin compatible")
PY

cd "$U"
make O=.output CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" CONFIG_DEFAULT_DEVICE_TREE=qcom/sm8150-oneplus-guacamole 2>&1 | tail -3

O=$U/.output
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
cd "$O"
gzip -9 -c u-boot-nodtb.bin > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb > uboot-dtb
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
"$MKB" --base 0x0 --kernel_offset 0x00008000 --pagesize 4096 \
       --kernel uboot-dtb -o "$OUT/uboot-guacamole-keys.img"
ls -lh "$OUT/uboot-guacamole-keys.img"
