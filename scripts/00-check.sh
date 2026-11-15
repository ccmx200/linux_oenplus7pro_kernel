#!/bin/bash
# WSL 环境自检：工具、镜像连通性、mmdebstrap 参数
set -u
echo "=== os"; . /etc/os-release; echo "$PRETTY_NAME"
echo "=== cpu/mem/disk"; nproc; free -g | head -2; df -h / | tail -1
echo "=== tools"
for t in aarch64-linux-gnu-gcc make bc bison flex mmdebstrap qemu-aarch64-static mkbootimg dtc git curl rsync; do
    printf '%-26s %s\n' "$t" "$(command -v "$t" || echo MISSING)"
done
echo "=== mkbootimg origin"; dpkg -S /usr/bin/mkbootimg 2>/dev/null || echo "(unknown)"
echo "=== binfmt"; ls /proc/sys/fs/binfmt_misc/ | grep -c . ; ls /proc/sys/fs/binfmt_misc/ | grep -i aarch64 || echo "NO aarch64 binfmt!"
echo "=== mmdebstrap flags"; mmdebstrap --help 2>&1 | grep -E '^\s+(-a|--arch|--variant|--include|--components|--keyring|--mode|--qemu)' | head -12
echo "=== mirrors"
for m in \
  https://mirrors.tuna.tsinghua.edu.cn/debian/dists/trixie/Release \
  https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/dists/noble/Release \
  https://mirrors.aliyun.com/ubuntu-ports/dists/noble/Release \
  https://git.yylx.win/github.com/GengWei1997/linux ; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$m")
    printf '%-80s %s\n' "$m" "$code"
done
echo "=== host build deps"
for p in build-essential bc bison flex libssl-dev libelf-dev libncurses-dev kmod cpio; do
    if dpkg -s "$p" >/dev/null 2>&1; then echo "OK   $p"; else echo "MISS $p"; fi
done
