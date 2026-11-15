#!/bin/bash
# 用 pmbootstrap 构建 Nura oneplus-guacamole 镜像（带 initramfs）
set -euo pipefail
export PATH=/root/.local/bin:/root/pmb/bin:$PATH
PMB=/root/pmb/bin/pmbootstrap
WORK=/root/.local/var/pmbootstrap
P=$WORK/cache_git/pmaports

echo "=== [$(date +%H:%M:%S)] pmaports"
mkdir -p "$WORK/cache_git" /root/.config
if [ ! -d "$P/.git" ]; then
    if [ -d /tmp/pmaports-gitlab/.git ]; then
        cp -a /tmp/pmaports-gitlab "$P"
    else
        git clone --depth=1 https://gitlab.com/postmarketOS/pmaports.git "$P"
    fi
fi
# pmbootstrap 3.12 需要 origin/main
git -C "$P" branch -m master main 2>/dev/null || true
git -C "$P" update-ref refs/remotes/origin/main "$(git -C "$P" rev-parse HEAD)"
git -C "$P" remote set-url origin https://gitlab.postmarketos.org/postMarketOS/pmaports.git
echo "pmaports: $(git -C "$P" log -1 --format='%h %ad' --date=short)  dev=$(ls -d $P/device/testing/device-oneplus-guacamole 2>/dev/null | wc -l)"

echo "=== [$(date +%H:%M:%S)] 配置"
echo 8 > "$WORK/version"
cat > /root/.config/pmbootstrap_v3.cfg <<'EOF'
[pmbootstrap]
device = oneplus-guacamole
ui = console
user = user
hostname = oneplus7pro
timezone = Asia/Shanghai
locale = C.UTF-8
is_default_channel = False
service_manager = openrc
extra_packages =
build_pkgs_on_install = False

[mirrors]
alpine = https://mirrors.tuna.tsinghua.edu.cn/alpine/
pmaports = https://mirrors.tuna.tsinghua.edu.cn/postmarketOS/
EOF

$PMB --version
echo "=== [$(date +%H:%M:%S)] install"
cd /root
$PMB --as-root -q -y update --arch aarch64 --non-existing 2>&1 | tail -15 || true
$PMB --as-root -y --details-to-stdout install --password 1234
echo "=== [$(date +%H:%M:%S)] done"
ls -lh "$WORK/chroot_native/home/pmos/rootfs/" 2>/dev/null || true
ls -lh "$WORK/chroot_rootfs_oneplus-guacamole/boot/" 2>/dev/null || true
