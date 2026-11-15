#!/bin/bash
# shell4: 最大化黑名单，只为进 initramfs 串口 shell
set -euo pipefail
W=/root/dbg-initrd
OUT=/root/op7p/out
SRC=/root/nura-kernel/linux
W2=/root/nura-kernel

[ -f "$W/initramfs.cpio.gz" ] || { echo "缺 initramfs"; exit 1; }
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$W2/kernel-dtb.gz"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)

BL="qcom_cpufreq_hw_init,dt_cpufreq_platdrv_init,cpufreq_dt_platdev_init,qnoc_driver_init,icc_init,thermal_init,msm_devfreq_init,ufshcd_pltfrm_init,qmp_ufs_driver_init,qcom_rpmhpd_init,cpufreq_core_init"
CMDLINE="console=tty0 console=ttyGS0,115200 fbcon=font:TER16x32 loglevel=7 ignore_loglevel oops=panic panic=0 clk_ignore_unused regulator_ignore_unused initcall_blacklist=$BL"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W2/kernel-dtb.gz" --ramdisk "$W/initramfs.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-shell4.img"
ls -lh "$OUT/nura-boot-shell4.img"
echo "cmdline: $CMDLINE"
