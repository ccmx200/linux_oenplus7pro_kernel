#!/bin/bash
# 用 pmbootstrap 构建 Nura 的 OnePlus 7 Pro (oneplus-guacamole) 镜像
# 学 Nura-raphael-ci 的配置方式，用清华镜像加速。
set -eu

export PATH=/root/.local/bin:/root/pmb/bin:$PATH
PMB=/root/pmb/bin/pmbootstrap
WORK=/root/.local/var/pmbootstrap

echo "=== [$(date +%H:%M:%S)] 安装 pmbootstrap"
if [ ! -x "$PMB" ]; then
    # venv 需要 python3.12-venv；先把 apt 源换清华再装
    if ! dpkg -s python3.12-venv >/dev/null 2>&1; then
        sed -i 's|http://archive.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g; s|http://security.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' \
            /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3.12-venv python3-pip
    fi
    python3 -m venv /root/pmb
    /root/pmb/bin/pip install -q --upgrade pip
    /root/pmb/bin/pip install -q "git+https://gitlab.nura.eco/nura/pmbootstrap.git@3.12.1" 2>&1 | tail -5
fi
$PMB --version

echo "=== [$(date +%H:%M:%S)] 写配置"
mkdir -p "$WORK/cache_git" /root/.config
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
service_manager = systemd
extra_packages =
build_pkgs_on_install = False

[mirrors]
alpine = https://mirrors.tuna.tsinghua.edu.cn/alpine/
pmaports = https://mirrors.tuna.tsinghua.edu.cn/postmarketOS/
systemd = https://mirrors.tuna.tsinghua.edu.cn/postmarketOS/extra-repos/systemd/
EOF

echo "=== [$(date +%H:%M:%S)] 准备 pmaports"
if [ ! -d "$WORK/cache_git/pmaports/.git" ]; then
    git clone --depth=1 https://gitlab.nura.eco/nura/pmaports.git "$WORK/cache_git/pmaports" 2>&1 | tail -3
fi
ls "$WORK/cache_git/pmaports/device/testing/device-oneplus-guacamole" >/dev/null && echo "device pkg: OK"

echo "=== [$(date +%H:%M:%S)] 开始 pmbootstrap install（会先 update，再装 rootfs）"
cd /root
$PMB -q -y update --arch aarch64 --non-existing 2>&1 | tail -20 || true
$PMB -y --details-to-stdout install --password 1234

echo "=== [$(date +%H:%M:%S)] 产物"
ls -lh "$WORK/chroot_native/home/pmos/rootfs/" 2>/dev/null || true
ls -lh "$WORK/chroot_rootfs_oneplus-guacamole/boot/" 2>/dev/null || true
