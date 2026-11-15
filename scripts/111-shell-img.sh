#!/bin/bash
# 在调试 initramfs 的基础上，跳过可疑 initcall，保证能进 shell
set -euo pipefail
W=/root/dbg-initrd
OUT=/root/op7p/out
SRC=/root/nura-kernel/linux
W2=/root/nura-kernel

[ -f "$W/initramfs.cpio.gz" ] || { echo "先跑 110 脚本生成 initramfs"; exit 1; }
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$W2/kernel-dtb.gz"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 console=ttyGS0,115200 fbcon=font:TER16x32 loglevel=7 ignore_loglevel oops=panic panic=0 initcall_blacklist=ufshcd_pltfrm_init,qcom_cpufreq_hw_init"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W2/kernel-dtb.gz" --ramdisk "$W/initramfs.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-shell.img"
ls -lh "$OUT/nura-boot-shell.img"
echo "cmdline: $CMDLINE"
