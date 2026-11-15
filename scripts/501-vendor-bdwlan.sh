#!/bin/bash
set -u
M=/mnt/vendorimg
mountpoint -q "$M" || mount -o ro,loop "/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/vendor.img" "$M"
echo "=== vendor 里含 bdwlan 字符串的文件"
grep -al 'bdwlan' -r "$M" 2>/dev/null | head -10
echo
echo "=== vendor/etc/wifi 与 wlan 目录"
ls "$M/etc/wifi" 2>/dev/null | head -15
ls "$M/firmware/wlan/qca_cld" 2>/dev/null
echo
echo "=== reserve1.img 类型与内容"
R="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/reserve1.img"
file "$R"
mkdir -p /mnt/reserve1
if mount -o ro,loop "$R" /mnt/reserve1 2>/dev/null; then
  echo mounted; find /mnt/reserve1 -maxdepth 3 | head -20; umount /mnt/reserve1
else
  echo "mount fail"; strings -n 8 "$R" | grep -i -m10 'bdwlan\|qca_cld\|wlan'
fi
