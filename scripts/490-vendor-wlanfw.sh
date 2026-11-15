#!/bin/bash
set -u
IMG="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/vendor.img"
ls -lh "$IMG"; file "$IMG"
M=/mnt/vendorimg; mkdir -p "$M"
SRC="$IMG"
# 处理 sparse
if file "$IMG" | grep -qi sparse; then
  echo "sparse，转换中..."; simg2img "$IMG" /root/vendor.raw.img && SRC=/root/vendor.raw.img
fi
if mount -o ro,loop "$SRC" "$M" 2>/dev/null; then
  echo "mounted"
  echo "=== wlan 固件相关"
  find "$M" -type d -iname '*wlan*' 2>/dev/null | head -10
  find "$M" -iname 'bdwlan*' -o -iname 'wlan_mac*' -o -iname 'board-2.bin*' -o -iname 'firmware-5.bin*' 2>/dev/null | head -20
  echo "=== firmware 目录"
  ls "$M" | head -10
  ls "$M/vendor/firmware" 2>/dev/null | head -20
  umount "$M"
else
  echo "mount 失败，列目录:"
  7z l "$SRC" 2>/dev/null | head -20
fi
