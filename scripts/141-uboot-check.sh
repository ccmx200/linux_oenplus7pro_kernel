#!/bin/bash
set -u
W=/root/uboot
cd "$W"
echo "=== branch: $(git branch --show-current 2>/dev/null)"
echo "=== remote heads"
git ls-remote --heads origin 2>/dev/null | head -10
echo "=== 本地 dts 目录里 sm8150 文件"
ls dts/upstream/src/arm64/qcom/ | grep -i 'sm8150\|oneplus' | head -20
echo "=== 搜 raphael 文件"
find . -name '*raphael*' -not -path './.git/*' | head -10
echo "=== git log 前 5"
git log --oneline -5
