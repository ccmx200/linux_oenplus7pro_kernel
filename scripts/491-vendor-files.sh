#!/bin/bash
set -u
M=/mnt/vendorimg
mountpoint -q "$M" || mount -o ro,loop "/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/vendor.img" "$M"
echo "=== firmware/ 列表"
ls "$M/firmware" | head -20
echo "=== 全盘搜 bdwlan / board / wlan 二进制"
find "$M" -type f \( -iname 'bdwlan*' -o -iname '*board*.bin' -o -iname 'wlan*' -o -iname '*.b0*' \) 2>/dev/null | head -30
echo "=== firmware_mnt / wireless"
ls "$M/firmware_mnt" 2>/dev/null | head
find "$M" -type d -iname '*wireless*' -o -type d -iname '*qca*' 2>/dev/null | head -10
echo "=== 大小统计"
du -sh "$M/firmware" "$M/etc/firmware" 2>/dev/null
