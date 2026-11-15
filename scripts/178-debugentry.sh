#!/bin/bash
# ESP 里加调试 initramfs（USB ACM shell），并设为默认启动项
set -euo pipefail
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1

cp -f /root/dbg-initrd/initramfs.cpio.gz /mnt/rp1/debug.cpio.gz
ls -lh /mnt/rp1/debug.cpio.gz

cat > /mnt/rp1/loader/entries/debug.conf <<'EOF'
title Debug shell (USB ACM, no rootfs)
linux /vmlinuz
initrd /debug.cpio.gz
devicetree /dtbs/qcom/sm8150-oneplus-guacamole.dtb
options console=tty0 console=ttyGS0,115200 loglevel=7 ignore_loglevel
EOF

cat > /mnt/rp1/loader/loader.conf <<'EOF'
default debug.conf
timeout 3
EOF
cat /mnt/rp1/loader/loader.conf
cat /mnt/rp1/loader/entries/debug.conf

sync
umount /mnt/rp1
losetup -d "$LOOP"
echo OK
