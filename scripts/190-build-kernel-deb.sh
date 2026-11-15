#!/bin/bash
# ?????? raphael/sm8150 ??? deb??CC ??????????????rootfs ?????set -euo pipefail
W=/root/kbuild
mkdir -p "$W"
cd "$W"

echo "=== ?????????"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq build-essential bc bison flex libssl-dev libelf-dev dpkg-dev debhelper kmod cpio rsync >/dev/null

if [ ! -d "$W/linux/.git" ]; then
    rm -rf "$W/linux"
    git clone --depth=1 --branch raphael-v7.3.0 https://git.yylx.win/github.com/GengWei1997/linux "$W/linux"
fi
cd "$W/linux"
echo "=== HEAD $(git log -1 --format='%h %s')"

cp -f /root/kernel-deb/raphael.config arch/arm64/configs/
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig raphael.config >/dev/null
echo "=== ???????$(date +%H:%M:%S)"
make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz dtbs modules 2>&1 | tail -5
echo "=== ??? deb $(date +%H:%M:%S)"
make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bindeb-pkg 2>&1 | tail -8
ls -lh "$W"/*.deb 2>/dev/null || ls -lh "$W/linux/../"*.deb 2>/dev/null

