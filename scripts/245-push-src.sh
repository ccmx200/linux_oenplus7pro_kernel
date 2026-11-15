#!/bin/bash
# 把带 guac 改动的内核源码推到 kernel-7.3.0-op7p 分支
set -uo pipefail
TOKEN="${GH_TOKEN:?need token}"
REPO="ccmx200/linux_oenplus7pro_kernel"
SRC=/root/kbuild/linux
W=/root/kernel-src

echo "=== 体积检查"
du -sh "$SRC" 2>/dev/null; df -h / | tail -1

rm -rf "$W"
mkdir -p "$W"
cd "$W"
git init -q
git config user.email "op7p@local"
git config user.name "op7p builder"
git remote add origin "https://x-access-token:${TOKEN}@github.com/${REPO}.git"

echo "=== 复制源码（排除构建产物）"
rsync -a --delete \
  --exclude='.git/' \
  --exclude='*.o' --exclude='*.ko' --exclude='*.cmd' --exclude='*.a' \
  --exclude='*.mod' --exclude='*.mod.c' --exclude='.*.cmd' \
  --exclude='.tmp_*' --exclude='*.dtb' --exclude='*.dtbo' \
  --exclude='vmlinux' --exclude='System.map' --exclude='Module.symvers' \
  --exclude='modules.order' --exclude='include/generated/' \
  --exclude='include/config/' --exclude='arch/arm64/boot/Image*' \
  --exclude='debian/' --exclude='scripts/basic/' \
  "$SRC"/ "$W"/

du -sh "$W"
git add -A
git -c user.email=op7p@local -c user.name="op7p builder" commit -q -m "Linux 7.3.0-sm8150 (GengWei1997 raphael-v7.3.0) + OnePlus 7 Pro guacamole DTS

- arch/arm64/boot/dts/qcom/sm8150-oneplus-{common.dtsi,guacamole.dts}
- dts Makefile 加入 sm8150-oneplus-guacamole.dtb
- scripts/Makefile.package: bindeb-pkg 跳过 dpkg 构建依赖检查
- 上游基线: GengWei1997/linux raphael-v7.3.0 (8611da353242)" 2>&1 | tail -3
git branch -M kernel-7.3.0-op7p
echo "=== 推送（走 31181 代理）"
git push -u origin kernel-7.3.0-op7p 2>&1 | tail -8
echo "=== PUSH_DONE"
