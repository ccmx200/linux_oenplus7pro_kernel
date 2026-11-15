#!/bin/bash
# 把新的单功能 USB 脚本塞进已有 rootfs.img（UUID 不变，不用改 boot.img）
set -e
O=/root/op7p/out
SRC=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro
M=/mnt/oproot
mkdir -p "$M"
mount -o loop "$O/rootfs.img" "$M"
install -m 755 "$SRC/usb/gadget-usb0.sh" "$M/usr/local/sbin/gadget-usb0.sh"
# 不要 ACM 了，去掉 ttyGS0 的 getty
rm -f "$M/etc/systemd/system/multi-user.target.wants/serial-getty@ttyGS0.service"
# 顺便确认 networkd 的 usb0 配置还在
ls -l "$M/etc/systemd/network/10-usb0.network"
sync
umount "$M"
echo "=== 重新生成 sparse/gz"
cd "$O"
img2simg rootfs.img rootfs.simg
gzip -9 -c rootfs.img > rootfs.img.gz
sha256sum boot.img rootfs.img rootfs.img.gz > SHA256SUMS
ls -lh boot.img rootfs.simg rootfs.img.gz
cat SHA256SUMS
