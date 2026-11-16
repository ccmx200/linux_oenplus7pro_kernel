#!/bin/bash
# 后台把完整内核源码推到分支 kernel-7.3.0-op7p
set -uo pipefail
K=/root/kbuild/linux
cd "$K" || exit 1
git config user.email op7p@local
git config user.name "op7p builder"

echo "=== 当前改动"
git status --short | head -20

BR=kernel-7.3.0-op7p
git checkout -B "$BR" 2>&1 | tail -2

# 只提交源码/配置相关文件
git add -A -- \
  arch/arm64/boot/dts/qcom/sm8150-oneplus-common.dtsi \
  arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dts \
  arch/arm64/boot/dts/qcom/Makefile \
  arch/arm64/configs/raphael.config \
  drivers/net/wireless/ath/ath10k/ \
  drivers/gpu/drm/panel/ \
  drivers/gpu/drm/msm/dsi/dsi_host.c \
  drivers/power/sequencing/pwrseq-qcom-wcn.c \
  arch/arm64/kernel/head.S \
  scripts/Makefile.package \
  include/drm/display/drm_dsc.h 2>&1 | tail -3

git commit -m "op7p: WiFi + DSC panel bring-up

- ath10k: MSA reclaim, INCOMPATIBLE_STATE recovery, wakeup (hotdog patches)
- panel: Samsung OnePlus DSC driver ported for guacamole DSI
- arm64: disable inherited APSS watchdog at entry (bring-up)
- dts: guac display (mdss/dsi/panel) + wifi supplies
- config: op7p kernel config
" 2>&1 | tail -5

echo "=== 提交结果"
git log --oneline -1
git show --stat --oneline HEAD | head -20

TOKEN="${GH_TOKEN:?token}"
REMOTE="https://x-access-token:${TOKEN}@github.com/ccmx200/linux_oenplus7pro_kernel.git"
git remote remove op7p 2>/dev/null
git remote add op7p "$REMOTE"
echo "=== 开始推送（体积大，可能较久）"
git push -f op7p "$BR:$BR" 2>&1 | tail -5
echo "KERNEL_PUSH_DONE"
