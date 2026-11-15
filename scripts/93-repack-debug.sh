#!/bin/bash
# 用 initcall_debug 重打 nura-boot.img（内核不变，只改 cmdline）
set -euo pipefail
SRC=/root/nura-kernel/linux
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
K=/root/nura-kernel/kernel-dtb.gz
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$K"
EMPTY=/root/op7p/work/empty.cpio.gz
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 root=UUID=$UUID rootfstype=ext4 rw rootwait loglevel=8 ignore_loglevel oops=panic panic=0 initcall_debug log_buf_len=2M"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$K" --ramdisk "$EMPTY" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-debug.img"
ls -lh "$OUT/nura-boot-debug.img"
echo "cmdline: $CMDLINE"
