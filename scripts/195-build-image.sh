#!/bin/bash
# 用刚编出来的内核 deb + 构建脚本做最小化 ubuntu-server rootfs.img
set -euo pipefail
IMG=/root/imgbuild
DEBDIR=$IMG/xiaomi-raphael-debs_7.3
mkdir -p "$DEBDIR"
cd /root/kbuild
cp -f linux-image-*-dirty_*_arm64.deb "$DEBDIR/linux-image-xiaomi-raphael.deb"
cp -f linux-headers-*-dirty_*_arm64.deb "$DEBDIR/linux-headers-xiaomi-raphael.deb"
cp -f /root/kernel-deb/firmware-xiaomi-raphael.deb "$DEBDIR/"
cp -f /root/kernel-deb/alsa-xiaomi-raphael.deb "$DEBDIR/"
ls -lh "$DEBDIR"

cd "$IMG"
export UBUNTU_VERSION=resolute
export DEBIAN_FRONTEND=noninteractive
bash ./build.sh ubuntu-server 7.3 "" "" false 2>&1 | tail -40
ls -lh "$IMG/rootfs.img"
