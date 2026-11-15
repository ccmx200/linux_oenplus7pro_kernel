#!/bin/bash
# 用 Nura/pmaports 的 sm8150-mainline 6.4 内核 + guacamole DTB + 我们的 Ubuntu rootfs
# 学 pmaports 的 config（228KB 完整 .config），只叠加启动必需项。
set -euo pipefail

PKG=/tmp/pmaports-gitlab/device/testing/linux-postmarketos-qcom-sm8150
W=/root/nura-kernel
SRC=$W/linux
ARCH=arm64
CROSS=aarch64-linux-gnu-
COMMIT=93f303701cafa17135d8ee563ffdc39f319783f1
URL="https://gitlab.com/sm8150-mainline/linux/-/archive/$COMMIT/linux-$COMMIT.tar.bz2"
CONFIG=$PKG/config-postmarketos-qcom-sm8150.aarch64

mkdir -p "$W"
echo "=== [$(date +%H:%M:%S)] 下载内核源码"
if [ ! -d "$SRC" ]; then
    if [ ! -f "$W/linux.tar.bz2" ]; then
        curl -L --max-time 900 -o "$W/linux.tar.bz2" "$URL"
    fi
    tar -xjf "$W/linux.tar.bz2" -C "$W"
    mv "$W/linux-$COMMIT" "$SRC"
fi
echo "源码: $(du -sh "$SRC" | cut -f1)"

cd "$SRC"
echo "=== [$(date +%H:%M:%S)] 配置"
cp -f "$CONFIG" .config
cp -f "$SRC"/../guacamole-bootfix.config /tmp/bootfix.config 2>/dev/null || true

# 启动必需覆盖（UFS 内建 / simpledrm / USB gadget / console）
cat > /tmp/bootfix.config <<'EOF'
CONFIG_LOCALVERSION="-guacamole"
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PLATFORM=y
CONFIG_SCSI_UFS_QCOM=y
CONFIG_PHY_QCOM_QMP=y
CONFIG_PHY_QCOM_QMP_UFS=y
CONFIG_PHY_QCOM_QUSB2=y
CONFIG_DRM_SIMPLEDRM=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FB=y
CONFIG_USB=y
CONFIG_USB_GADGET=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_GADGET=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_RNDIS=y
CONFIG_USB_CONFIGFS_NCM=y
CONFIG_USB_U_ETHER=y
CONFIG_USB_F_NCM=y
CONFIG_USB_F_RNDIS=y
CONFIG_CONFIGFS_FS=y
CONFIG_EXT4_FS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
EOF
./scripts/kconfig/merge_config.sh -m .config /tmp/bootfix.config >/dev/null
make ARCH=$ARCH CROSS_COMPILE=$CROSS olddefconfig >/dev/null

echo "=== [$(date +%H:%M:%S)] 关键项检查"
for c in CONFIG_SCSI_UFS_QCOM=y CONFIG_DRM_SIMPLEDRM=y CONFIG_USB_CONFIGFS_RNDIS=y CONFIG_EXT4_FS=y; do
    grep -qx "$c" .config && echo "OK   $c" || echo "MISS $c"
done
echo "guac DTS: $(ls arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dts 2>/dev/null || echo MISSING)"

echo "=== [$(date +%H:%M:%S)] 编译"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j"$(nproc)" Image.gz dtbs 2>&1 | tail -20

echo "=== [$(date +%H:%M:%S)] 产物"
ls -lh arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb

# 打 boot.img（内核 + appended guac DTB，root UUID 用我们 Ubuntu 镜像的）
OUT=/root/op7p/out
UUID=$(cat "$OUT/root-uuid.txt")
K="$W/kernel-dtb.gz"
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb > "$K"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 root=UUID=$UUID rootfstype=ext4 rw rootwait loglevel=8 ignore_loglevel oops=panic panic=0"
# 空 ramdisk（和之前一致）
EMPTY=/root/op7p/work/empty.cpio.gz
[ -f "$EMPTY" ] || { printf '0707010000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000' > /tmp/e.cpio; gzip -9 -n -c /tmp/e.cpio > "$EMPTY"; }
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$K" --ramdisk "$EMPTY" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot.img"
ls -lh "$OUT/nura-boot.img"
echo "cmdline: $CMDLINE"
