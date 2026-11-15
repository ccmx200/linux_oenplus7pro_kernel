#!/bin/bash
set -u
IMG="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/modem.img"
ls -lh "$IMG"
file "$IMG"
echo "=== 尝试挂载/查看内容"
M=/mnt/modemimg
mkdir -p "$M"
if mount -o ro,loop "$IMG" "$M" 2>/dev/null; then
  echo "mounted"; find "$M" -maxdepth 3 | head -20; umount "$M"
else
  echo "mount 失败，试 7z 列表"
  command -v 7z >/dev/null || apt-get install -y -qq p7zip-full >/dev/null 2>&1
  7z l "$IMG" 2>/dev/null | head -25
fi
