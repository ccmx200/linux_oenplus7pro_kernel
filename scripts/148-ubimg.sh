#!/bin/bash
# 打包 guacamole U-Boot 成 Android boot.img（同 CI 做法）
set -euo pipefail
U=/root/uboot
O=$U/.output
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
mkdir -p "$OUT"
cd "$O"
gzip -9 -c u-boot-nodtb.bin > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb > uboot-dtb
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
"$MKB" --base 0x0 --kernel_offset 0x00008000 --pagesize 4096 \
       --kernel uboot-dtb -o "$OUT/uboot-guacamole.img"
ls -lh "$OUT/uboot-guacamole.img"
