#!/bin/bash
set -euo pipefail
SRC=/root/nura-kernel/linux
D=$SRC/arch/arm64/boot/dts/qcom
ARCH=arm64
CROSS=aarch64-linux-gnu-

echo "=== 还原 guac dts 再追加"
git -C "$SRC" checkout -- arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dts
cat >> "$D/sm8150-oneplus-guacamole.dts" <<'EOF'

/* 首启最小化：关掉需要固件加载的子系统，避免无 initramfs 时的 60s 超时 */
&remoteproc_mpss { status = "disabled"; };
&remoteproc_adsp { status = "disabled"; };
&remoteproc_slpi { status = "disabled"; };
&remoteproc_cdsp { status = "disabled"; };
&wifi { status = "disabled"; };
EOF

echo "=== 编 DTB"
cd "$SRC"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" dtbs 2>&1 | tail -4
ls -l arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb

echo "=== 重打 verbose boot.img"
W=/root/nura-kernel
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb > "$W/kernel-dtb.gz"
mkdir -p /tmp/emptydir
( cd /tmp/emptydir && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 -n > "$W/empty.cpio.gz" )
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 fbcon=font:TER16x32 loglevel=7 ignore_loglevel root=UUID=$UUID rootfstype=ext4 rw rootwait oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W/kernel-dtb.gz" --ramdisk "$W/empty.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-nofw.img"
ls -lh "$OUT/nura-boot-nofw.img"
