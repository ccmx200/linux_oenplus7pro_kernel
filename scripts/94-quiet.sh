#!/bin/bash
# 静默启动版：少打印，避免 fbcon 拖慢内核；出问题仍会打 ERR
set -euo pipefail
SRC=/root/nura-kernel/linux
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
K=/root/nura-kernel/kernel-dtb.gz
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$K"
EMPTY=/root/op7p/work/empty.cpio.gz
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 quiet loglevel=3 root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$K" --ramdisk "$EMPTY" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-quiet.img"
ls -lh "$OUT/nura-boot-quiet.img"
echo "cmdline: $CMDLINE"
