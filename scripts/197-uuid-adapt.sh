#!/bin/bash
# 1) 保证 p2 的 UUID 是固定值 2) 跑 7 Pro 适配脚本
set -euo pipefail
IMG=/root/imgbuild/rootfs.img
TARGET=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
echo "loop=$LOOP"
blkid ${LOOP}p2 || true
UUID=$(blkid -s UUID -o value ${LOOP}p2)
echo "p2 UUID=$UUID  target=$TARGET"
if [ "$UUID" != "$TARGET" ]; then
    e2fsck -f -y ${LOOP}p2 >/dev/null 2>&1 || true
    tune2fs -U "$TARGET" ${LOOP}p2 >/dev/null
    echo "UUID 已设置为 $(blkid -s UUID -o value ${LOOP}p2)"
fi
losetup -d "$LOOP"

bash /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/wsl/191-adapt-image.sh "$IMG"
