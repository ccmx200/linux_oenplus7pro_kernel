#!/bin/bash
# 关掉内建 g_ether（CONFIG_USB_ETH），让用户的 configfs RNDIS 接管 UDC；
# 顺便用合法的空 newc cpio 当 ramdisk，消除 "junk at end of compressed archive"。
set -euo pipefail
SRC=/root/nura-kernel/linux
W=/root/nura-kernel
OUT=/root/op7p/out
ARCH=arm64
CROSS=aarch64-linux-gnu-

cd "$SRC"
echo "=== [$(date +%H:%M:%S)] 关掉 g_ether"
cat > /tmp/usbfix.config <<'EOF'
# CONFIG_USB_ETH is not set
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_RNDIS=y
CONFIG_USB_CONFIGFS_NCM=y
CONFIG_USB_CONFIGFS_ACM=y
CONFIG_USB_F_NCM=y
CONFIG_USB_F_RNDIS=y
CONFIG_USB_F_ACM=y
CONFIG_USB_U_ETHER=y
EOF
./scripts/kconfig/merge_config.sh -m .config /tmp/usbfix.config >/dev/null
make ARCH=$ARCH CROSS_COMPILE=$CROSS olddefconfig >/dev/null
grep -E 'CONFIG_USB_ETH|CONFIG_USB_CONFIGFS_RNDIS' .config

echo "=== [$(date +%H:%M:%S)] 重新编译"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" Image.gz dtbs 2>&1 | tail -5

echo "=== [$(date +%H:%M:%S)] 生成合法空 initramfs + 打 boot.img"
mkdir -p /tmp/emptydir
( cd /tmp/emptydir && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 -n > "$W/empty.cpio.gz" )
ls -l "$W/empty.cpio.gz"

UUID=$(cat "$OUT/root-uuid.txt")
K=$W/kernel-dtb.gz
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb > "$K"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=4 root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$K" --ramdisk "$W/empty.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-configfs.img"
ls -lh "$OUT/nura-boot-configfs.img"
echo "cmdline: $CMDLINE"
