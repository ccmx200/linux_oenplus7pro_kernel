#!/bin/bash
# 让内建 g_ether 默认 RNDIS（Windows 可用），重编内核并打包 boot.img（无 initramfs）
set -euo pipefail
SRC=/root/nura-kernel/linux
W=/root/nura-kernel
OUT=/root/op7p/out
ARCH=arm64
CROSS=aarch64-linux-gnu-

cd "$SRC"
echo "=== 恢复 g_ether 编译并改默认 rndis"
cat > /tmp/ethfix.config <<'EOF'
CONFIG_USB_ETH=y
CONFIG_USB_ETH_RNDIS=y
EOF
./scripts/kconfig/merge_config.sh -m .config /tmp/ethfix.config >/dev/null
make ARCH=$ARCH CROSS_COMPILE=$CROSS olddefconfig >/dev/null
grep -E '^CONFIG_USB_ETH' .config

echo "=== patch 默认值"
f=drivers/usb/gadget/legacy/ether.c
grep -n "static.*rndis" $f | head -5
sed -i 's/^static bool rndis;$/static bool rndis = true;/' $f
sed -i 's/^static bool rndis = false;$/static bool rndis = true;/' $f
grep -n "static.*rndis" $f | head -5

echo "=== 编译"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" Image.gz dtbs 2>&1 | tail -4

UUID=$(cat "$OUT/root-uuid.txt")
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb > "$W/kernel-dtb.gz"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=7 ignore_loglevel root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W/kernel-dtb.gz" --ramdisk /dev/null --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-rndis2.img" 2>/dev/null || \
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W/kernel-dtb.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-rndis2.img"
ls -lh "$OUT/nura-boot-rndis2.img"
