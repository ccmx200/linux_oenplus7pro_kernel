#!/bin/bash
set -euo pipefail
K=/root/nura-kernel/linux
echo "=== UFS / SCSI 相关配置"
grep -E '^CONFIG_SCSI=|^CONFIG_BLK_DEV_SD|^CONFIG_SCSI_UFS|^CONFIG_PHY_QCOM_QMP_UFS|^CONFIG_PHY_QCOM_QUSB2|^CONFIG_ARM_SMMU' "$K/.config"

echo "=== 打 verbose boot.img（loglevel=7，慢慢刷屏）"
SRC=$K
W=/root/nura-kernel
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$W/kernel-dtb.gz"
( mkdir -p /tmp/emptydir && cd /tmp/emptydir && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 -n > "$W/empty.cpio.gz" )
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=7 ignore_loglevel root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W/kernel-dtb.gz" --ramdisk "$W/empty.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-verbose.img"
ls -lh "$OUT/nura-boot-verbose.img"
echo "cmdline: $CMDLINE"
