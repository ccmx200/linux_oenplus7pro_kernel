#!/bin/bash
# 修正 pmaports 分支名（旧镜像默认 master，pmbootstrap 3.12 要 origin/main）
set -eu
P=/root/.local/var/pmbootstrap/cache_git/pmaports
cd "$P"
git branch -m master main 2>/dev/null || true
git update-ref refs/remotes/origin/main "$(git rev-parse HEAD)"
git remote set-url origin https://gitlab.postmarketos.org/postMarketOS/pmaports.git
echo "branch: $(git branch --show-current)"
echo "origin/main: $(git rev-parse --short refs/remotes/origin/main 2>/dev/null)"
echo "channels.cfg: $(git show origin/main:channels.cfg 2>/dev/null | head -3 | tr '\n' ' ')"
echo "device pkg: $(ls -d device/testing/device-oneplus-guacamole 2>/dev/null)"
echo "kernel pkg: $(ls -d device/testing/linux-postmarketos-qcom-sm8150 2>/dev/null)"
