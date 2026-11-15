#!/bin/bash
set -u
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1
D=/mnt/rp1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh "$D"
dtc -I dtb -O dts "$D" -o /tmp/guac-k.dts 2>/dev/null
echo "=== simple-framebuffer / chosen"
grep -n -A8 'framebuffer' /tmp/guac-k.dts | head -30
grep -n -A6 'chosen' /tmp/guac-k.dts | head -20
echo "=== 是否有 panel 节点"
grep -n 'panel@\|panel {' /tmp/guac-k.dts | head -5
echo "=== 内存节点大小（ABL 会补）"
grep -n -A4 'memory@80000000' /tmp/guac-k.dts | head -8
umount /mnt/rp1
losetup -d "$LOOP"
