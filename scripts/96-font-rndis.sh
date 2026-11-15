#!/bin/bash
# 1) 重新配置内核：加大字体（TER16x32）
# 2) 重打 boot.img：cmdline 加 g_ether.rndis=1（让内建 g_ether 走 RNDIS，Windows 才能认）
set -euo pipefail
SRC=/root/nura-kernel/linux
W=/root/nura-kernel
OUT=/root/op7p/out
ARCH=arm64
CROSS=aarch64-linux-gnu-

cd "$SRC"
echo "=== [$(date +%H:%M:%S)] 加字体配置"
cat > /tmp/fontfix.config <<'EOF'
CONFIG_FONTS=y
CONFIG_FONT_TER16x32=y
CONFIG_FONT_8x16=y
CONFIG_FONT_8x8=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_USB_ETH_RNDIS=y
EOF
./scripts/kconfig/merge_config.sh -m .config /tmp/fontfix.config >/dev/null
make ARCH=$ARCH CROSS_COMPILE=$CROSS olddefconfig >/dev/null
grep -E 'CONFIG_FONT_TER16x32|CONFIG_FONTS=' .config

echo "=== [$(date +%H:%M:%S)] 重新编译（字体变了要重编 vmlinux）"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" Image.gz dtbs 2>&1 | tail -6

echo "=== [$(date +%H:%M:%S)] 重打 boot.img"
UUID=$(cat "$OUT/root-uuid.txt")
K=$W/kernel-dtb.gz
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb > "$K"
EMPTY=/root/op7p/work/empty.cpio.gz
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=4 g_ether.rndis=1 g_ether.host_addr=02:11:22:33:44:55 g_ether.dev_addr=02:11:22:33:44:56 root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$K" --ramdisk "$EMPTY" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-rndis.img"
ls -lh "$OUT/nura-boot-rndis.img"
echo "cmdline: $CMDLINE"
