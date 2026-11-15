#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq libdw-dev libssl-dev >/dev/null
cd /root/kbuild/linux
make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bindeb-pkg 2>&1 | tail -10
ls -lh /root/kbuild/*.deb 2>/dev/null || ls -lh /root/kbuild/linux/../*.deb 2>/dev/null || true
