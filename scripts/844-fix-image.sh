#!/bin/bash
set -uo pipefail
IMG=/root/img-fix.img
SRC=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/rootfs-op7p.img
WORK=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/sm8150-guac-wifi-work.dtb
ls -lh "$SRC" "$WORK"
[ -f "$IMG" ] || cp --sparse=always "$SRC" "$IMG"
losetup -D 2>/dev/null
LOOP=$(losetup --find --show --partscan "$IMG")
echo "loop=$LOOP"
sleep 2
lsblk "$LOOP"
mkdir -p /mnt/esp
mount "${LOOP}p1" /mnt/esp 2>/dev/null || { echo "p1 mount fail"; ls /mnt/esp; }
echo "=== ESP 内容"
ls /mnt/esp | head
ls /mnt/esp/dtbs/qcom 2>/dev/null | head
cp -f "$WORK" /mnt/esp/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh /mnt/esp/dtbs/qcom/sm8150-oneplus-guacamole.dtb
sync
umount /mnt/esp
losetup -d "$LOOP"
echo "=== 镜像已修正"
