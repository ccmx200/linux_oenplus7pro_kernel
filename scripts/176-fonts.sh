#!/bin/bash
set -u
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1
EX=/root/nura-kernel/linux/scripts/extract-ikconfig
"$EX" /mnt/rp1/vmlinuz > /tmp/kcfg 2>/dev/null || true
echo "=== 内核自带字体（决定能不能放大字）"
grep -E '^CONFIG_FONT' /tmp/kcfg
echo
echo "=== 调试 initramfs 是否还在"
ls -lh /root/dbg-initrd/initramfs.cpio.gz 2>/dev/null || echo "(缺)"
echo
echo "=== ESP 现有文件"
ls -lh /mnt/rp1 | head
cat /mnt/rp1/loader/loader.conf 2>/dev/null
umount /mnt/rp1
losetup -d "$LOOP"
