#!/bin/bash
# 导出 Nura 构建产物到 Windows 工作区（sparse 加速传输）
set -euo pipefail
W=/root/.local/var/pmbootstrap
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
mkdir -p "$OUT"

BOOT=$W/chroot_rootfs_oneplus-guacamole/boot/boot.img
ROOT=$W/chroot_native/home/pmos/rootfs/oneplus-guacamole.img

echo "=== 产物"
ls -lh "$BOOT" "$ROOT"

echo "=== 转 sparse（rootfs）"
if command -v img2simg >/dev/null 2>&1; then
    img2simg "$ROOT" /tmp/nura-rootfs.simg
    ls -lh /tmp/nura-rootfs.simg
    cp -f /tmp/nura-rootfs.simg "$OUT/nura-rootfs.simg"
else
    echo "img2simg 缺失，直接拷 raw"
    cp -f "$ROOT" "$OUT/nura-rootfs.img"
fi
cp -f "$BOOT" "$OUT/nura-boot.img"
echo "=== 已导出"
ls -lh "$OUT"
