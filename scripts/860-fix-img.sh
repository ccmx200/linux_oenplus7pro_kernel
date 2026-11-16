#!/bin/bash
set -uo pipefail
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
SRC=$OUT/rootfs-op7p.img
FIX=$OUT/rootfs-fixed.img
WORK=$OUT/sm8150-guac-wifi-work.dtb
df -h /mnt/c | tail -1
[ -f "$FIX" ] || cp --sparse=always "$SRC" "$FIX"
ls -lh "$FIX"
losetup -D 2>/dev/null
LOOP=$(losetup --find --show --partscan "$FIX")
sleep 2
lsblk "$LOOP" | head
mkdir -p /mnt/esp2
mount "${LOOP}p1" /mnt/esp2 || { echo "mount p1 失败"; exit 1; }
echo "=== ESP 内容"
ls /mnt/esp2 | head
ls /mnt/esp2/dtbs/qcom 2>/dev/null | head -3
cp -f "$WORK" /mnt/esp2/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh /mnt/esp2/dtbs/qcom/sm8150-oneplus-guacamole.dtb
sync
umount /mnt/esp2
losetup -d "$LOOP"
echo "镜像已修正"
