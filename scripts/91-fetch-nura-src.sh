#!/bin/bash
set -u
echo "=== 下载到的 5984 字节是什么"
head -c 600 /root/nura-kernel/linux.tar.bz2 2>/dev/null; echo
echo
echo "=== gitlab.com sm8150-mainline/linux 是否可 git 访问"
timeout 30 git ls-remote https://gitlab.com/sm8150-mainline/linux.git HEAD 2>&1 | head -3
echo
echo "=== 直接 clone 该 commit（浅）"
rm -rf /root/nura-kernel/linux
mkdir -p /root/nura-kernel/linux
cd /root/nura-kernel/linux
git init -q .
git remote add origin https://gitlab.com/sm8150-mainline/linux.git
if timeout 300 git fetch --depth=1 origin 93f303701cafa17135d8ee563ffdc39f319783f1 2>&1 | tail -5; then
    git checkout -q FETCH_HEAD 2>&1 | tail -3
    echo "checkout done: $(git log -1 --format='%h %s' | head -1)"
    ls arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dts && echo "DTS OK"
else
    echo "FETCH FAILED"
fi
