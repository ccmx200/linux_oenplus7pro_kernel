#!/bin/bash
# 更新仓库：dts/脚本/pwrseq 补丁，后台推送
set -u
TOKEN="${GH_TOKEN:?token}"
REPO="ccmx200/linux_oenplus7pro_kernel"
W=/root/kernel-repo
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro

cd "$W" || exit 1
git config user.email op7p@local
git config user.name "op7p builder"

mkdir -p dts scripts patches
cp -f "$C"/dts/*.dts "$C"/dts/*.dtsi dts/ 2>/dev/null
cp -f "$C"/wsl/*.sh scripts/ 2>/dev/null

# pwrseq 驱动补丁（若存在）
if [ -f /root/pwrseq-swctrl.patch ]; then
  cp -f /root/pwrseq-swctrl.patch patches/0003-pwrseq-qcom-wcn-add-swctrl-gpio.patch
fi

git add -A
git commit -q -m "wcn3998: S4A vddio/boot-on, pwrseq regulators, wifi supplies; add swctrl patch + scripts" 2>&1 | tail -2
REMOTE="https://x-access-token:${TOKEN}@github.com/${REPO}.git"
git remote set-url origin "$REMOTE"
git push origin HEAD:main 2>&1 | tail -3
echo "PUSH_DONE"
