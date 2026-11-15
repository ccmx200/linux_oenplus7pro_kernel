#!/bin/bash
set -u
IMG=/root/imgbuild/rootfs.img
L=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
if [ -z "$L" ]; then L=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; fi
echo "loop=$L"
mkdir -p /mnt/chk
mount "${L}p1" /mnt/chk || { echo "mount fail"; exit 1; }
echo "=== ESP 根"; ls /mnt/chk
echo "=== EFI"; find /mnt/chk/EFI -maxdepth 3 2>/dev/null | head -10
echo "=== loader"; ls /mnt/chk/loader/entries 2>/dev/null; cat /mnt/chk/loader/loader.conf 2>/dev/null
echo "=== 启动文件"; ls -lh /mnt/chk/vmlinuz /mnt/chk/initrd.img 2>/dev/null
umount /mnt/chk
losetup -d "$L" 2>/dev/null || true
