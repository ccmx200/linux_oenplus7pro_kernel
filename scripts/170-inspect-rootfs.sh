#!/bin/bash
# 离线检查用户刷入的 rootfs.img（raphael 镜像）结构、密码、启动项
set -u
IMG="/mnt/c/迅雷下载/rootfs.img"
if [ ! -f "$IMG" ]; then echo "找不到 $IMG"; exit 1; fi
ls -lh "$IMG"
echo "=== 分区表（扇区 4096）"
partx -s -o NR,START,SECTORS,SIZE,TYPE "$IMG" 2>/dev/null || true
fdisk -l "$IMG" 2>/dev/null | tail -8

LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show 2>&1) || { echo "losetup 失败: $LOOP"; exit 1; }
echo "loop=$LOOP"
sleep 1
lsblk "$LOOP" -o NAME,SIZE,FSTYPE,LABEL 2>/dev/null

mkdir -p /mnt/rp1 /mnt/rp2
mount ${LOOP}p1 /mnt/rp1 2>/dev/null && echo "p1 mounted" || echo "p1 mount fail"
mount ${LOOP}p2 /mnt/rp2 2>/dev/null && echo "p2 mounted" || echo "p2 mount fail"

echo "=== ESP 结构"
find /mnt/rp1 -maxdepth 3 2>/dev/null | head -40
echo "=== loader 配置"
for f in /mnt/rp1/loader/loader.conf /mnt/rp1/loader/entries/*.conf /mnt/rp1/EFI/BOOT/*.conf; do
    [ -f "$f" ] && { echo "--- $f"; cat "$f"; }
done
echo "=== root 的 /boot"
ls -lh /mnt/rp2/boot 2>/dev/null | head -20
echo "=== shadow 前几行"
grep -E '^(root|user):' /mnt/rp2/etc/shadow 2>/dev/null
echo "=== sshd 配置"
ls /mnt/rp2/etc/ssh/sshd_config.d/ 2>/dev/null
grep -rE 'PermitRootLogin|PasswordAuthentication|KbdInteractive' /mnt/rp2/etc/ssh/ 2>/dev/null | head -10
echo "=== os-release"
cat /mnt/rp2/etc/os-release 2>/dev/null | head -3
