#!/bin/bash
# ??pmbootstrap ??? Nura ??? oneplus-guacamole ?????? initramfs??set -euo pipefail
export PATH=/root/.local/bin:/root/pmb/bin:$PATH
PMB=/root/pmb/bin/pmbootstrap
WORK=/root/.local/var/pmbootstrap

echo "=== [$(date +%H:%M:%S)] ??? pmaports"
mkdir -p "$WORK/cache_git" /root/.config
if [ ! -d "$WORK/cache_git/pmaports/.git" ]; then
    if [ -d /tmp/pmaports-gitlab/.git ]; then
        cp -a /tmp/pmaports-gitlab "$WORK/cache_git/pmaports"
    else
        echo "??gitlab.com ??? pmaports?????
        git clone --depth=1 https://gitlab.com/postmarketOS/pmaports.git "$WORK/cache_git/pmaports"
    fi
fi
echo "pmaports: $(du -sh "$WORK/cache_git/pmaports" | cut -f1)  $(git -C "$WORK/cache_git/pmaports" log -1 --format=%h 2>/dev/null)"

echo "=== [$(date +%H:%M:%S)] ?????
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
echo "=== [$(date +%H:%M:%S)] pmbootstrap install"
cd /root
$PMB --as-root -q -y update --arch aarch64 --non-existing 2>&1 | tail -15 || true
$PMB --as-root -y --details-to-stdout install --password 1234
echo "=== [$(date +%H:%M:%S)] done"
ls -lh "$WORK/chroot_native/home/pmos/rootfs/" 2>/dev/null || true
ls -lh "$WORK/chroot_rootfs_oneplus-guacamole/boot/" 2>/dev/null || true

