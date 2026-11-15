#!/bin/bash
# 通用重打包：101-repack.sh "<额外cmdline>" <输出名>
set -euo pipefail
EXTRA="${1:-}"
NAME="${2:?输出名}"
SRC=/root/nura-kernel/linux
W=/root/nura-kernel
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$W/kernel-dtb.gz"
mkdir -p /tmp/emptydir
( cd /tmp/emptydir && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 -n > "$W/empty.cpio.gz" )
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=7 ignore_loglevel root=UUID=$UUID rootfstype=ext4 rw oops=panic panic=0 $EXTRA"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W/kernel-dtb.gz" --ramdisk "$W/empty.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/$NAME"
ls -lh "$OUT/$NAME"
echo "cmdline: $CMDLINE"
