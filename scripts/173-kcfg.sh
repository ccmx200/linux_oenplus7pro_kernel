#!/bin/bash
set -u
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1
K=/mnt/rp1/vmlinuz
ls -lh "$K" /mnt/rp1/initrd.img
echo "=== 提取内核 config"
EX=/root/nura-kernel/linux/scripts/extract-ikconfig
if [ -x "$EX" ] && "$EX" "$K" > /tmp/kcfg 2>/dev/null && [ -s /tmp/kcfg ]; then
    echo "config 提取成功 $(wc -l < /tmp/kcfg) 行"
    grep -E '^CONFIG_(DRM_SIMPLEDRM|DRM_FBDEV_EMULATION|FRAMEBUFFER_CONSOLE|FB|FB_SIMPLE|DRM=|DRM_QCOM|DRM_MSM|USB_CONFIGFS_NCM|USB_F_NCM|USB_CONFIGFS|USB_GADGET|CONFIGFS_FS)=' /tmp/kcfg | head -25
else
    echo "没有内嵌 config，改用 strings 判断"
    strings "$K" | grep -m5 -i 'simpledrm'
fi
echo "=== initrd 里是否有 NCM/网络脚本"
mkdir -p /tmp/ird && cd /tmp/ird
( zcat /mnt/rp1/initrd.img 2>/dev/null || cat /mnt/rp1/initrd.img ) | cpio -idm --quiet 2>/dev/null
ls | head -10
grep -rl 'ncm\|usb0\|172.16.42.1' . 2>/dev/null | head -10
cd /
rm -rf /tmp/ird
umount /mnt/rp1
losetup -d "$LOOP"
